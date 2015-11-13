//
//  DRUIPopUpMainController.m
//  RichPopUp
//
//  Created by Donky Networks on 13/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DRUIPopUpMainController.h"
#import "DNDonkyCore.h"
#import "DNConstants.h"
#import "UIViewController+DNRootViewController.h"
#import "NSDate+DNDateHelper.h"
#import "DNLoggingController.h"
#import "DRConstants.h"
#import "DNDataController.h"

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
        if ([[event data] isKindOfClass:[NSArray class]] || [[event data] isKindOfClass:[NSDictionary class]]) {
            NSManagedObjectContext *tempContext = [DNDataController temporaryContext];
            [tempContext performBlock:^{
                NSArray *messages = nil;
                if ([[event data] isKindOfClass:[NSDictionary class]]) {
                    messages = [event data][@"RichMessage"];
                }
                else {
                    messages = [event data];
                }
                [messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSManagedObjectID *objectID = [obj objectID];
                    if (objectID) {
                        DNRichMessage *richMessage = [tempContext existingObjectWithID:objectID error:nil];
                        if ([weakSelf isDisplayingPopUp] && [obj isKindOfClass:[DNRichMessage class]] && ![[weakSelf pendingMessages] containsObject:richMessage]) {
                            [[weakSelf pendingMessages] addObject:richMessage];
                        }
                        else if ([obj isKindOfClass:[DNRichMessage class]]) {
                            [weakSelf presentPopUp:richMessage];
                        }
                    }
                }];
            }];
        }
        else {
            if ([weakSelf isDisplayingPopUp] && [[event data] isKindOfClass:[DNRichMessage class]] && ![[weakSelf pendingMessages] containsObject:event]) {
                [[weakSelf pendingMessages] addObject:event];
            }
            else if ([[event data] isKindOfClass:[DNRichMessage class]]){
                [weakSelf presentPopUp:event];
            }
        }
    }];
    
    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDRichMessageNotificationEvent handler:[self richMessageHandler]];

    DNModuleDefinition *richModule = [[DNModuleDefinition alloc] initWithName:NSStringFromClass([self class]) version:@"1.1.0.1"];
    [[DNDonkyCore sharedInstance] registerModule:richModule];


    //Get unread chat messages:
    NSArray *unreadChat = [[self donkyRichLogicController] allUnreadRichMessages];

    //We don't want this to block the thread:
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [unreadChat enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            DNRichMessage *richMessage = obj;
            DNLocalEvent *richEvent = [[DNLocalEvent alloc] initWithEventType:kDRichMessageNotificationEvent
                                                                    publisher:NSStringFromClass([self class])
                                                                    timeStamp:[NSDate date]
                                                                         data:richMessage];
            [[DNDonkyCore sharedInstance] publishEvent:richEvent];
        }];
    });
}

- (void)stop {
    [[self donkyRichLogicController] stop];
    [[DNDonkyCore sharedInstance] unSubscribeToLocalEvent:kDRichMessageNotificationEvent handler:[self richMessageHandler]];
}

- (void)presentPopUp:(id)message {

    DNRichMessage *richMessage = [message isKindOfClass:[DNRichMessage class]] ? message : [message data];

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
            [self performSelector:@selector(presentPopUp:) withObject:message afterDelay:0.25];
            return;
        }

        [[self donkyRichLogicController] markMessageAsRead:richMessage];

        UINavigationController *popOverViewController = [popUpController richPopUpNavigationControllerWithModalPresentationStyle:[self richPopUpPresentationStyle]];
        if (popOverViewController) {
            [self setDisplayingPopUp:YES];
            [applicationViewController presentViewController:popOverViewController
                                                    animated:YES
                                                  completion:nil];
            
            DNLocalEvent *event = [[DNLocalEvent alloc] initWithEventType:@"DCMAudioPlayAudioFile" publisher:NSStringFromClass([self class]) timeStamp:[NSDate date] data:@(0)];
            [[DNDonkyCore sharedInstance] publishEvent:event];
        }
    }

    if ([[self pendingMessages] containsObject:message]) {
        [[self pendingMessages] removeObject:message];
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
