//
//  DRLogicMainControllerHelper.m
//  RichInbox
//
//  Created by Donky Networks on 23/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//


#import "DRLogicMainControllerHelper.h"
#import "DNServerNotification.h"
#import "DRLogicHelper.h"
#import "DNConstants.h"
#import "DNDonkyCore.h"
#import "DCMMainController.h"
#import "DNLoggingController.h"
#import "DNDataController.h"
#import "DRConstants.h"
#import "NSMutableDictionary+DNDictionary.h"


@implementation DRLogicMainControllerHelper

+ (DNSubscriptionBatchHandler)richMessageHandler:(DRLogicMainController *)mainController {

    DNSubscriptionBatchHandler richMessageHandler = ^(NSArray *batch) {
        NSMutableArray *newNotifications = [[NSMutableArray alloc] init];
        NSArray *allRichMessages = batch;
        NSManagedObjectContext *temp = [DNDataController temporaryContext];
        [temp performBlock:^{
            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
                [allRichMessages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    DNServerNotification *notification = obj;
                    if (![mainController doesRichMessageExistForID:[notification serverNotificationID]]) {
                        NSManagedObjectID *objectID = [[DRLogicHelper saveRichMessage:obj context:temp] objectID];
                        if (objectID) {
                            DNRichMessage *richMessage = (DNRichMessage *) [temp existingObjectWithID:objectID error:nil];
                            if (richMessage) {
                                [DCMMainController markMessageAsReceived:obj];
                                [newNotifications addObject:richMessage];
                                if ([batch count] == 1) {
                                    DNLocalEvent *event = [[DNLocalEvent alloc] initWithEventType:@"DAudioPlayAudioFile" publisher:NSStringFromClass([self class]) timeStamp:[NSDate date] data:@(1)];
                                    [[DNDonkyCore sharedInstance] publishEvent:event];
                                }
                            }
                            else {
                                DNErrorLog(@"Could not create rich message from server notification: %@", obj);
                            }
                        }
                        else {
                            DNInfoLog(@"This is a duplicate message, do nothing...");
                        }
                    }
                }];
            }

            [[DNDataController sharedInstance] saveContext:temp];

            [mainController richMessageNotificationsReceived:newNotifications];

            if ([batch count] > 1) {
                DNLocalEvent *event = [[DNLocalEvent alloc] initWithEventType:@"DAudioPlayAudioFile" publisher:NSStringFromClass([self class]) timeStamp:[NSDate date] data:@(1)];
                [[DNDonkyCore sharedInstance] publishEvent:event];
            }

            DNLocalEvent *localEvent = [[DNLocalEvent alloc] initWithEventType:kDRichMessageNotificationEvent
                                                                     publisher:NSStringFromClass([mainController class])
                                                                     timeStamp:[NSDate date]
                                                                          data:newNotifications];
            [[DNDonkyCore sharedInstance] publishEvent:localEvent];
        }];
    };

    return richMessageHandler;
}

+ (DNLocalEventHandler)notificationLoaded:(DRLogicMainController *)mainController {

    DNLocalEventHandler notificationLoaded = ^(DNLocalEvent *event) {

        DNServerNotification *notification = [event data];

        //If we aren't looking at a rich message, we bail out:
        if (![[notification notificationType] isEqualToString:kDNDonkyNotificationRichMessage]) {
            return;
        }

        __block DNRichMessage *richMessage = nil;
        
        NSDictionary *data = [notification data];

        BOOL messageExists = [mainController doesRichMessageExistForID:data[@"messageId"]];

        NSManagedObjectContext *tempContext = [DNDataController temporaryContext];

        [tempContext performBlock:^{
            if (!messageExists) {
                NSManagedObjectID *objectID = [[DRLogicHelper saveRichMessage:notification context:tempContext] objectID];
                if (objectID) {
                    richMessage = [tempContext existingObjectWithID:objectID error:nil];
                    if (![[richMessage silentNotification] boolValue]) {
                        DNLocalEvent *audioEvent = [[DNLocalEvent alloc] initWithEventType:@"DAudioPlayAudioFile" publisher:NSStringFromClass([self class]) timeStamp:[NSDate date] data:@(1)];
                        [[DNDonkyCore sharedInstance] publishEvent:audioEvent];
                    }
                }
            }
            else if (messageExists) {
                NSManagedObjectID *objectID = [[DRLogicHelper richMessageForID:data[@"messageId"] context:tempContext] objectID];
                if (objectID) {
                    richMessage = [tempContext existingObjectWithID:objectID error:nil];
                }
            }

            [[DNDataController sharedInstance] saveContext:tempContext];

            if (richMessage) {
                DNLocalEvent *richEvent = [[DNLocalEvent alloc] initWithEventType:kDRichMessageNotificationTapped
                                                                        publisher:NSStringFromClass([mainController class])
                                                                        timeStamp:[NSDate date]
                                                                             data:richMessage];
                [[DNDonkyCore sharedInstance] publishEvent:richEvent];
            }

            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive) {
                //We are in multi tasking, so need to increment badge count:
                NSInteger count = [[UIApplication sharedApplication] applicationIconBadgeNumber];
                count += 1;

                DNLocalEvent *changeBadgeEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkySetBadgeCount
                                                                               publisher:NSStringFromClass([DRLogicMainControllerHelper class])
                                                                               timeStamp:[NSDate date]
                                                                                    data:@(count)];
                [[DNDonkyCore sharedInstance] publishEvent:changeBadgeEvent];
            }
        }];
    };

    return notificationLoaded;
}

+ (DNLocalEventHandler)backgroundNotificationsReceived:(NSMutableArray *)notifications {
    DNLocalEventHandler backgroundNotifications = ^(DNLocalEvent *event) {
        [notifications addObject:[event data][@"NotificationID"]];
    };
    return backgroundNotifications;
}

+ (void)richMessageNotificationReceived:(NSArray *)notifications backgroundNotifications:(NSMutableArray *)backgroundNotifications {

    __block NSMutableArray *backgroundNotificationsToKeep = [[NSMutableArray alloc] init];
    __block NSMutableArray *notificationsToKeep = [notifications mutableCopy];

    [notifications enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DNRichMessage *richMessage = obj;
        [backgroundNotifications enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx2, BOOL *stop2) {
            if ([obj2 isEqualToString:[richMessage notificationID]]) {
                [backgroundNotificationsToKeep addObject:richMessage];
                [notificationsToKeep removeObject:richMessage];
                *stop2 = YES;
            }
        }];
    }];

    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        //We need to increment the badge count here as the badge count is not incremented automatically when
        //the app is open and a notification is received.
        NSInteger count = [[UIApplication sharedApplication] applicationIconBadgeNumber];
        count += [notificationsToKeep count] - [backgroundNotificationsToKeep count];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
    }

    //Publish event:
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data dnSetObject:backgroundNotificationsToKeep forKey:kDRPendingRichNotifications];
    [data dnSetObject:notificationsToKeep forKey:kDNDonkyNotificationRichMessage];

    DNLocalEvent *pushEvent = [[DNLocalEvent alloc] initWithEventType:kDRichMessageNotificationEvent
                                                            publisher:NSStringFromClass([self class])
                                                            timeStamp:[NSDate date]
                                                                 data:data];
    [[DNDonkyCore sharedInstance] publishEvent:pushEvent];
}

@end
