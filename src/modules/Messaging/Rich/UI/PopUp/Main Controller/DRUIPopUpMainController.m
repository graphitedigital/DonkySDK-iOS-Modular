//
//  DRUIPopUpMainController.m
//  RichPopUp
//
//  Created by Chris Watson on 13/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DRUIPopUpMainController.h"
#import "DNDonkyCore.h"
#import "DNConstants.h"
#import "UIViewController+DNRootViewController.h"
#import "NSDate+DNDateHelper.h"
#import "DNLoggingController.h"

@interface DRUIPopUpMainController ()
@property(nonatomic, strong) DRLogicMainController *donkyRichLogicController;
@property(nonatomic, copy) void (^richMessageHandler)(DNLocalEvent *);
@property(nonatomic, strong) NSMutableArray *pendingMessages;
@property(nonatomic, getter=isDisplayingPopUp) BOOL displayingPopUp;
@end

@implementation DRUIPopUpMainController


+(DRUIPopUpMainController *)sharedInstance
{
    static dispatch_once_t pred;
    static DRUIPopUpMainController *sharedInstance = nil;

    dispatch_once(&pred, ^{
        sharedInstance = [[DRUIPopUpMainController alloc] initPrivate];
    });

    return sharedInstance;
}

-(instancetype)init {
    return [self initPrivate];
}

-(instancetype)initPrivate
{
    self  = [super init];

    if (self) {
        [self setDonkyRichLogicController:[[DRLogicMainController alloc] init]];
        [[self donkyRichLogicController] start];

        [self setPendingMessages:[[NSMutableArray alloc] init]];
        [self setAutoDelete:YES];
        [self setVibrate:YES];
    }

    return self;
}


- (void)start {

    __weak DRUIPopUpMainController *weakSelf = self;

    [self setRichMessageHandler:^(DNLocalEvent *event) {
        if ([weakSelf isDisplayingPopUp] && [[event data] isKindOfClass:[DNRichMessage class]]) {
            [[weakSelf pendingMessages] addObject:event];
        }
        else if ([[event data] isKindOfClass:[DNRichMessage class]]){
            [weakSelf presentPopUp:event];
        }
    }];
    
    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDNDonkyNotificationRichMessage handler:[self richMessageHandler]];

    DNModuleDefinition *richModule = [[DNModuleDefinition alloc] initWithName:NSStringFromClass([self class]) version:@"1.1.0.1"];
    [[DNDonkyCore sharedInstance] registerModule:richModule];


    //Get unread chat messages:
    NSArray *unreadChat = [[self donkyRichLogicController] allUnreadRichMessages];

    //We don't want this to block the thread:
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [unreadChat enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            DNRichMessage *richMessage = obj;
            DNLocalEvent *richEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyNotificationRichMessage
                                                                    publisher:NSStringFromClass([self class])
                                                                    timeStamp:[NSDate date]
                                                                         data:richMessage];
            [[DNDonkyCore sharedInstance] publishEvent:richEvent];
        }];
    });
}

- (void)stop {
    [[self donkyRichLogicController] stop];
    [[DNDonkyCore sharedInstance] unSubscribeToLocalEvent:kDNDonkyNotificationRichMessage handler:[self richMessageHandler]];
}

- (void)presentPopUp:(DNLocalEvent *)event {

    DNRichMessage *richMessage = [event data];

    if ([[richMessage messageReceivedTimestamp] donkyHasMessageExpired]) {
        DNInfoLog(@"Rich message: %@ is more than 30 days old... Deleting message.", [richMessage messageID]);
        [[self donkyRichLogicController] deleteMessage:richMessage];
    }

    else {

        DRMessageViewController *popUpController = [[DRMessageViewController alloc] initWithRichMessage:richMessage];
        [popUpController setDelegate:self];

        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:popUpController action:NSSelectorFromString(@"closeView:")];
        [popUpController addBarButtonItem:buttonItem buttonSide:DMVLeftSide];

        UIViewController *applicationViewController = [UIViewController applicationRootViewController];

        if (![applicationViewController isViewLoaded]) {
            [self performSelector:@selector(presentPopUp:) withObject:event afterDelay:0.25];
            return;
        }

        [[self donkyRichLogicController] markMessageAsRead:richMessage];

        UINavigationController *popOverViewController = [popUpController richPopUpNavigationControllerWithModalPresentationStyle:[self richPopUpPresentationStyle]];
        if (popOverViewController) {
            [self setDisplayingPopUp:YES];
            [applicationViewController presentViewController:popOverViewController
                                                    animated:YES
                                                  completion:nil];

            if ([self shouldVibrate] && ![richMessage silentNotification]) {
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
            }
        }
    }

    if ([[self pendingMessages] containsObject:event]) {
        [[self pendingMessages] removeObject:event];
    }
}

- (void)richMessagePopUpWasClosed:(NSString *)messageID {

    [self setDisplayingPopUp:NO];

    if ([self shouldAutoDelete]) {
        [[self donkyRichLogicController] deleteMessage:[[self donkyRichLogicController] richMessageWithID:messageID]];
    }

    if ([[self pendingMessages] count]) {
        [self presentPopUp:[[self pendingMessages] firstObject]];
    }
}

@end
