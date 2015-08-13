//
//  DRIMainControllerHelper.m
//  RichInbox
//
//  Created by Chris Watson on 23/06/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import "DRIMainControllerHelper.h"
#import "DNSystemHelpers.h"
#import "UIViewController+DNRootViewController.h"
#import "DNConstants.h"
#import "DRConstants.h"
#import "DNDonkyCore.h"
#import "DRINotification.h"
#import "NSDate+DNDateHelper.h"

static NSString *const DRIExpiryTimeStamp = @"expiryTimeStamp";
static NSString *const DRIType = @"type";
static NSString *const DRIMessageID = @"messageID";

@implementation DRIMainControllerHelper

+ (DNLocalEventHandler)richMessageTapped:(DRIMainController *)mainController {

    DNLocalEventHandler richMessageTapped = ^(id data) {
        DNLocalEvent *event = data;
        if ([[event data] isKindOfClass:[DNRichMessage class]] && mainController.shouldLoadTappedMessage) {
            DRIMessageViewController *richMessageViewController = [[DRIMessageViewController alloc] initWithRichMessage:[event data]];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:richMessageViewController];
            [richMessageViewController addBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:richMessageViewController action:NSSelectorFromString(@"closeView:")] buttonSide:DMVLeftSide];

            UIViewController *presentingViewController = [UIViewController applicationRootViewController];

            if ([DNSystemHelpers isDeviceIPad]) {
                [navigationController setModalPresentationStyle:mainController.iPadModelPresentationStyle];
            }

            [presentingViewController presentViewController:navigationController animated:YES completion:nil];

            [mainController.richLogicController markMessageAsRead:[event data]];
        }
    };

    return richMessageTapped;
}

+ (DNLocalEventHandler)bannerTapped:(DRIMainController *)mainController notificationController:(DCUINotificationController *)notificationController {

    DNLocalEventHandler bannerTappedHandler = ^(DNLocalEvent *event) {
        if ([[event data][DRIType] isEqualToString:kDNDonkyNotificationRichMessage]) {
            [notificationController bannerDismissTimerDidTick];

            //Get message ID:
            NSString *messageID = [event data][DRIMessageID];
            DNRichMessage *richMessage = [mainController.richLogicController richMessageWithID:messageID];

            if (richMessage) {
                //Present as pop over:
                DNLocalEvent *popUpMessageEvent = [[DNLocalEvent alloc] initWithEventType:kDRichMessageNotificationTapped publisher:NSStringFromClass([mainController class]) timeStamp:[NSDate date] data:richMessage];
                [[DNDonkyCore sharedInstance] publishEvent:popUpMessageEvent];
            }
        }
    };

    return bannerTappedHandler;
}

+ (DNLocalEventHandler)richMessageBadgeCount {

    DNLocalEventHandler richMessageBadgeCount = ^(DNLocalEvent *event) {

        NSInteger count = [[UIApplication sharedApplication] applicationIconBadgeNumber];
        count -= [[event data] integerValue];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            DNLocalEvent *changeBadgeEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkySetBadgeCount
                                                                           publisher:NSStringFromClass([DRIMainControllerHelper class])
                                                                           timeStamp:[NSDate date]
                                                                                data:@(count)];
            [[DNDonkyCore sharedInstance] publishEvent:changeBadgeEvent];
        });

    };

    return richMessageBadgeCount;
}

+ (void)processNotifications:(NSDictionary *)notificationData notificationController:(DCUINotificationController *)notificationController richLogicController:(DRLogicMainController *)richLogicController showBannerView:(BOOL)showBannerView {

    NSArray *notifications = notificationData[kDNDonkyNotificationRichMessage];

    __block BOOL duplicate = NO;

    NSArray *backgroundNotifications = notificationData[kDRPendingRichNotifications];

    [notifications enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

        DNServerNotification *notification = obj;

        [backgroundNotifications enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx2, BOOL *stop2) {
            NSString *notificationID = obj2;
            if ([notificationID isEqualToString:[notification serverNotificationID]]) {
                duplicate = YES;
                *stop = YES;
            }
        }];

        NSDate *expired = [NSDate donkyDateFromServer:[notification data][DRIExpiryTimeStamp]];

        BOOL messageExpired = NO;
        if (expired)
            messageExpired = [expired donkyHasDateExpired];

        DRINotification *donkyNotification = [[DRINotification alloc] initWithNotification:notification customBody:[notification data][@"description"]];

        if (!duplicate && !messageExpired) {

            id presentingView = [UIViewController applicationRootViewController];

            __block BOOL inboxShown = NO;

            if ([presentingView isKindOfClass:[UITabBarController class]]) {
                presentingView = (UITabBarController *) [presentingView selectedViewController];
            }

            if ([presentingView isKindOfClass:[DCUISplitViewController class]]) {
                inboxShown = YES;
            }

            if ([presentingView respondsToSelector:@selector(viewControllers)] && !inboxShown) {
                [[presentingView viewControllers] enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx2, BOOL *stop2) {
                    if ([obj2 isKindOfClass:[DCUISplitViewController class]]) {
                        inboxShown = YES;
                        if (inboxShown) {
                            *stop2 = YES;
                        }
                    }
                    inboxShown = [self isInboxView:obj2];
                    if (inboxShown) {
                        *stop2 = YES;
                    }
                    if ([obj2 respondsToSelector:@selector(viewControllers)]) {
                        [[obj2 viewControllers] enumerateObjectsUsingBlock:^(id obj3, NSUInteger idx3, BOOL *stop3) {
                            inboxShown = [self isInboxView:obj3];
                            if (inboxShown) {
                                *stop2 = YES;
                            }
                        }];
                    }
                }];
            }

            if ([DNSystemHelpers systemVersionAtLeast:8.0]) {
                if ([presentingView isKindOfClass:[UIAlertController class]] || [presentingView isKindOfClass:[UIActivityViewController class]]) {
                    return;
                }
            }
            else {
                if ([presentingView isKindOfClass:[UIActivityViewController class]]) {
                    return;
                }
            }

            if (!inboxShown) {
                DCUIBannerView *bannerView = [[DCUIBannerView alloc] initWithSenderDisplayName:[donkyNotification senderDisplayName]
                                                                                          body:[donkyNotification body]
                                                                               messageSentTime:[donkyNotification sentTimeStamp]
                                                                                 avatarAssetID:[donkyNotification avatarAssetID]
                                                                              notificationType:kDNDonkyNotificationRichMessage
                                                                                     messageID:[donkyNotification messageID]];
                [notificationController presentNotification:bannerView];

                //If we are on simple push, we add the other gestures:
                if (![bannerView buttonView]) {
                    [notificationController.notificationBannerView configureGestures];
                }
            }
        }
        else if (duplicate) {
            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
                DNRichMessage *richMessage = [richLogicController richMessageWithID:[donkyNotification messageID]];
                //Present as pop over:
                DNLocalEvent *popUpMessageEvent = [[DNLocalEvent alloc] initWithEventType:kDRichMessageNotificationTapped
                                                                                publisher:NSStringFromClass([DRIMainControllerHelper class])
                                                                                timeStamp:[NSDate date]
                                                                                     data:richMessage];
                [[DNDonkyCore sharedInstance] publishEvent:popUpMessageEvent];
            }
        }
    }];
}

+ (BOOL)isInboxView:(id)viewController {
    BOOL inboxView = NO;
    if ([viewController isKindOfClass:[DRITableViewController class]] || [viewController isKindOfClass:[DRIMessageViewController class]]) {
        inboxView = YES;
    }

    return inboxView;
}

@end
