//
//  DRLogicMainControllerHelper.m
//  RichInbox
//
//  Created by Donky Networks on 23/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

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
#import "DRLogicMainController.h"
#import "NSManagedObject+DNHelper.h"

@implementation DRLogicMainControllerHelper

+ (DNSubscriptionBatchHandler)richMessageHandler {

    return ^(NSArray *batch) {
        NSMutableArray *newNotifications = [[NSMutableArray alloc] init];
        NSArray *allRichMessages = batch;
        NSManagedObjectContext *temp = [DNDataController temporaryContext];
        [temp performBlock:^{
            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
                [allRichMessages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    DNServerNotification *notification = obj;
                    if (![DRLogicMainController doesRichMessageExistForID:[notification serverNotificationID]]) {
                        NSManagedObjectID *objectID = [[DRLogicHelper saveRichMessage:obj context:temp] objectID];
                        if (objectID) {
                            DNRichMessage *richMessage =  [temp existingObjectWithID:objectID error:nil];
                            if (richMessage) {
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

            [DCMMainController markAllMessagesAsReceived:allRichMessages];

            [[DNDataController sharedInstance] saveContext:temp];

            [DRLogicMainController richMessageNotificationsReceived:newNotifications];

            if ([batch count] > 1) {
                DNLocalEvent *event = [[DNLocalEvent alloc] initWithEventType:@"DAudioPlayAudioFile" publisher:NSStringFromClass([self class]) timeStamp:[NSDate date] data:@(1)];
                [[DNDonkyCore sharedInstance] publishEvent:event];
            }

            DNLocalEvent *localEvent = [[DNLocalEvent alloc] initWithEventType:kDRichMessageNotificationEvent
                                                                     publisher:NSStringFromClass([DRLogicMainControllerHelper class])
                                                                     timeStamp:[NSDate date]
                                                                          data:allRichMessages];
            [[DNDonkyCore sharedInstance] publishEvent:localEvent];
        }];
    };
}

+ (DNSubscriptionBatchHandler)richMessageReadHandler {
    return ^(NSArray *batch) {
        NSManagedObjectContext *tempContext = [DNDataController temporaryContext];
        [tempContext performBlock:^{
            [batch enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DNServerNotification *serverNotification = obj;
                NSString *messageID = [serverNotification data][@"messageId"];
                
                DNRichMessage *richMessage = [DNRichMessage fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"messageID == %@", messageID] withContext:tempContext includesPendingChanges:YES];
                if (richMessage) {
                    [DRLogicMainController markMessageAsRead:richMessage];
                }
            }];
            [[DNDataController sharedInstance] saveContext:tempContext];
        }];
        
        DNLocalEvent *localEvent = [[DNLocalEvent alloc] initWithEventType:kDRichMessageReadOnAnotherDeviceEvent
                                                                 publisher:NSStringFromClass([DRLogicMainControllerHelper class])
                                                                 timeStamp:[NSDate date]
                                                                      data:batch];
        [[DNDonkyCore sharedInstance] publishEvent:localEvent];
    };
}

+ (DNSubscriptionBatchHandler)richMessageDeleted {
    return ^(NSArray *batch) {
        NSManagedObjectContext *tempContext = [DNDataController temporaryContext];
        [tempContext performBlock:^{
            [batch enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DNServerNotification *serverNotification = obj;
                NSString *messageID = [serverNotification data][@"messageId"];
                
                DNRichMessage *richMessage = [DNRichMessage fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"messageID == %@", messageID] withContext:tempContext includesPendingChanges:YES];
                if (richMessage) {
                    [tempContext deleteObject:richMessage];
                }
            }];
            [[DNDataController sharedInstance] saveContext:tempContext];
        }];
        
        DNLocalEvent *localEvent = [[DNLocalEvent alloc] initWithEventType:kDRichMessageDeletedEvent
                                                                 publisher:NSStringFromClass([DRLogicMainControllerHelper class])
                                                                 timeStamp:[NSDate date]
                                                                      data:batch];
        [[DNDonkyCore sharedInstance] publishEvent:localEvent];
    };
}

+ (void)richMessageNotificationReceived:(NSArray *)notifications backgroundNotifications:(NSMutableArray *)backgroundNotifications {

    __block NSMutableArray *backgroundNotificationsToKeep = [[NSMutableArray alloc] init];
    __block NSMutableArray *notificationsToKeep = [notifications mutableCopy];
    __block NSMutableArray *richMessageIDs = [[NSMutableArray alloc] init];

    [notifications enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DNRichMessage *richMessage = obj;
        [richMessageIDs addObject:[richMessage messageID]];
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
    [data dnSetObject:richMessageIDs forKey:kDNDonkyNotificationRichMessage];

    DNLocalEvent *pushEvent = [[DNLocalEvent alloc] initWithEventType:kDRichMessageNotificationEvent
                                                            publisher:NSStringFromClass([self class])
                                                            timeStamp:[NSDate date]
                                                                 data:data];
    [[DNDonkyCore sharedInstance] publishEvent:pushEvent];
}

@end
