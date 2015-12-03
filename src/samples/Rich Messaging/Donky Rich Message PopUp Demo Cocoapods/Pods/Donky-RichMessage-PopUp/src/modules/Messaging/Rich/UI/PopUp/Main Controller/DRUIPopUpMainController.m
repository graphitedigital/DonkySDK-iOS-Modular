//
//  DRUIPopUpMainController.m
//  RichPopUp
//
//  Created by Chris Watson on 13/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DRUIPopUpMainController.h"
#import "DNLocalEvent.h"
#import "DRMessageViewController.h"
#import "DNDonkyCore.h"
#import "DRLogicMainController.h"
#import "DNConstants.h"
#import "UIViewController+DNRootViewController.h"
#import "DRLogicMainController.h"
#import "DNRichMessage.h"
#import "NSDate+DNDateHelper.h"
#import "DNLoggingController.h"

@interface DRUIPopUpMainController ()
@property(nonatomic, strong) DRLogicMainController *donkyRichLogicController;
@property(nonatomic, copy) void (^richMessageHandler)(DNLocalEvent *);
@property(nonatomic, strong) NSMutableArray *pendingMessages;
@property(nonatomic) BOOL displayingPopUp;
@end

@implementation DRUIPopUpMainController


+(DRUIPopUpMainController *)sharedInstance
{
    static dispatch_once_t pred;
    static DRUIPopUpMainController *sharedInstance = nil;

    @synchronized (sharedInstance) {
        if (sharedInstance)
            return sharedInstance;
    }

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
        self.donkyRichLogicController = [[DRLogicMainController alloc] init];
        [self.donkyRichLogicController start];
        
        self.pendingMessages = [[NSMutableArray alloc] init];
        self.autoDelete = YES;
    }

    return self;
}


- (void)start {

    __weak DRUIPopUpMainController *weakSelf = self;

    self.richMessageHandler = ^(DNLocalEvent *event) {
        if ([weakSelf displayingPopUp] && [[event data] isKindOfClass:[DNRichMessage class]]) {
            [[weakSelf pendingMessages] addObject:event];
        }
        else if ([[event data] isKindOfClass:[DNRichMessage class]]){
            [weakSelf presentPopUp:event];
        }
    };
    
    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDNDonkyNotificationRichMessage handler:self.richMessageHandler];

    DNModuleDefinition *richModule = [[DNModuleDefinition alloc] initWithName:NSStringFromClass([self class]) version:@"1.1.0.0"];
    [[DNDonkyCore sharedInstance] registerModule:richModule];
  
}

- (void)stop {
    [[self donkyRichLogicController] stop];
    [[DNDonkyCore sharedInstance] unSubscribeToLocalEvent:kDNDonkyNotificationRichMessage handler:self.richMessageHandler];
}

- (void)presentPopUp:(DNLocalEvent *)event {

    DNRichMessage *richMessage = [event data];

    NSDate *thirtyDaysExpired = [[NSDate date] dateByAddingTimeInterval:(3600 * 24 * 30) * -1];

    if ([[richMessage messageReceivedTimestamp] isDateBeforeDate:thirtyDaysExpired]) {
        DNInfoLog(@"Rich message: %@ is more than 30 days old... Marking as read and deleting message.", [richMessage messageID]);
        [[self donkyRichLogicController] markMessageAsRead:richMessage];
        [[self donkyRichLogicController] deleteMessage:richMessage];
    }

    else {

        DRMessageViewController *popUpController = [[DRMessageViewController alloc] initWithRichMessage:richMessage];
        [popUpController setDelegate:self];

        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:popUpController action:NSSelectorFromString(@"closeView:")];
        [popUpController addBarButtonItem:buttonItem buttonSide:DMVLeftSide];

        UIViewController *applicationViewController = [UIViewController applicationRootViewController];

        if (!applicationViewController.isViewLoaded) {
            [self performSelector:@selector(presentPopUp:) withObject:event afterDelay:0.25];
            return;
        }

        [[self donkyRichLogicController] markMessageAsRead:richMessage];

        UINavigationController *popOverViewController = [popUpController richPopUpNavigationControllerWithModalPresentationStyle:self.richPopUpPresentationStyle];
        if (popOverViewController) {
            self.displayingPopUp = YES;
            [applicationViewController presentViewController:popOverViewController
                                                    animated:YES
                                                  completion:nil];
        }
    }

    if ([[self pendingMessages] containsObject:event])
        [[self pendingMessages] removeObject:event];

}

//TODO: Change to message obj
- (void)richMessagePopUpWasClosed:(NSString *)messageID {
    self.displayingPopUp = NO;

    if ([self shouldAutoDelete])
        [[self donkyRichLogicController] deleteMessage:[self.donkyRichLogicController richMessageWithID:messageID]];

    if ([[self pendingMessages] count])
        [self presentPopUp:[[self pendingMessages] firstObject]];
}

@end
