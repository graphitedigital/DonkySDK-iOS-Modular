//
//  DCMMainController.m
//  Common Messaging
//
//  Created by Donky Networks on 07/04/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DCMMainController.h"
#import "DNClientNotification.h"
#import "DNNetworkController.h"
#import "NSMutableDictionary+DNDictionary.h"
#import "NSDate+DNDateHelper.h"
#import "DNDataController.h"
#import "DCMConstants.h"

static NSString *const DCMDelivered = @"delivered";
static NSString *const DCMResult = @"result";
static NSString *const DCMMessageReceived = @"MessageReceived";
static NSString *const DCMMessageDeleted = @"MessageDeleted";
static NSString *const DCMType = @"type";
static NSString *const DCMReceivedExpired = @"receivedExpired";
static NSString *const DCMessageType = @"messageType";
static NSString *const DCMessageRead = @"MessageRead";
static NSString *const DCMMessageShared = @"messageShared";
static NSString *const DCMSharedTimestamp = @"sharedTimestamp";
static NSString *const DCMOriginalMessageSentTimestamp = @"originalMessageSentTimestamp";
static NSString *const DCMSharedTo = @"sharedTo";
static NSString *const DCMTimeToReadSeconds = @"timeToReadSeconds";

@implementation DCMMainController

+ (void)markMessageAsReceived:(DNServerNotification *)notification {
    [DCMMainController markAllMessagesAsReceived:@[notification]];
}

+ (void)markAllMessagesAsReceived:(NSArray *)notifications {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSMutableArray *clientNotifications = [[NSMutableArray alloc] init];
        
        [notifications enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
           
            NSDictionary *notificationData = [obj data];
            
            NSMutableDictionary *messageReceived = [[NSMutableDictionary alloc] init];
            
            BOOL messageExpired = [[NSDate donkyDateFromServer:notificationData[DCMExpiryTimeStamp]] donkyHasDateExpired];
            
            [messageReceived dnSetObject:DCMMessageReceived forKey:DCMType];
            [messageReceived dnSetObject:notificationData[DCMSenderInternalUserID] forKey:DCMSenderInternalUserID];
            [messageReceived dnSetObject:notificationData[DCMMessageID] forKey:DCMMessageID];
            [messageReceived dnSetObject:notificationData[DCMSenderMessageID] forKey:DCMSenderMessageID];
            [messageReceived dnSetObject:messageExpired ? @"true" : @"false" forKey:DCMReceivedExpired];
            [messageReceived dnSetObject:notificationData[DCMessageType] forKey:DCMMessageType];
            [messageReceived dnSetObject:notificationData[DCMMessageScope] forKey:DCMMessageScope];
            [messageReceived dnSetObject:notificationData[DCMSentTimestamp] forKey:DCMSentTimestamp];
            [messageReceived dnSetObject:notificationData[DCMContextItems] forKey:DCMContextItems];
            
            DNClientNotification *msgReceived = [[DNClientNotification alloc] initWithType:DCMMessageReceived data:messageReceived acknowledgementData:obj];
            [[msgReceived acknowledgementDetails] dnSetObject:DCMDelivered forKey:DCMResult];
            
            [clientNotifications addObject:msgReceived];
        }];

        [[DNNetworkController sharedInstance] queueClientNotifications:clientNotifications completion:^(id data) {
            [[DNNetworkController sharedInstance] synchronise];
        }];
    });
}


+ (void)markMessageAsRead:(DNMessage *)message {

    if (!message) {
        return;
    }

    [DCMMainController markAllMessagesAsRead:@[message]];
}

+ (void)markAllMessagesAsRead:(NSArray *)messages {
    NSMutableArray *clientNotifications = [[NSMutableArray alloc] init];
    NSManagedObjectContext *tempContext = [DNDataController temporaryContext];
    [tempContext performBlock:^{
        [messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            DNMessage *message = obj;
            NSManagedObjectID *objectID =  [message objectID];
            if (objectID) {
                DNMessage *fetchedMessage = [tempContext existingObjectWithID:objectID error:nil];
                if (![[fetchedMessage read] boolValue]) {
                    [fetchedMessage setRead:@(YES)];
                    DNClientNotification *messageReadNotification = [[DNClientNotification alloc] initWithType:DCMessageRead data:[DCMMainController messageRead:fetchedMessage] acknowledgementData:nil];
                    [clientNotifications addObject:messageReadNotification];
                }
            }
        }];

        [[DNDataController sharedInstance] saveContext:tempContext];
        [[DNNetworkController sharedInstance] queueClientNotifications:clientNotifications completion:^(id data) {
            [[DNNetworkController sharedInstance] synchronise];
        }];
    }];
}

+ (NSDictionary *)messageRead:(DNMessage *)message {

    NSMutableDictionary *messageRead = [[NSMutableDictionary alloc] init];

    [messageRead dnSetObject:[message senderInternalUserID] forKey:DCMSenderInternalUserID];
    [messageRead dnSetObject:[message messageID] forKey:DCMMessageID];
    [messageRead dnSetObject:[message senderMessageID] forKey:DCMSenderMessageID];
    [messageRead dnSetObject:[message messageType] forKey:DCMMessageType];
    [messageRead dnSetObject:[message messageScope] forKey:DCMMessageScope];
    [messageRead dnSetObject:[[message sentTimestamp] donkyDateForServer] forKey:DCMSentTimestamp];
    [messageRead dnSetObject:[message contextItems] forKey:DCMContextItems];

    NSTimeInterval timeToRead = [[NSDate date] timeIntervalSinceDate:[message messageReceivedTimestamp]];
    [messageRead dnSetObject:isnan(timeToRead) ? @(0) : @(timeToRead) forKey:DCMTimeToReadSeconds];

    return messageRead;

}

+ (void)reportSharingOfRichMessage:(DNMessage *)message sharedUsing:(NSString *)sharedUsing {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if (sharedUsing) {
            NSMutableDictionary *messageShared = [[NSMutableDictionary alloc] init];

            [messageShared dnSetObject:[message messageID] forKey:DCMMessageID];
            [messageShared dnSetObject:[message messageType] forKey:DCMessageType];
            [messageShared dnSetObject:[message messageScope] forKey:DCMMessageScope];
            [messageShared dnSetObject:[DCMMainController shareType:sharedUsing] forKey:DCMSharedTo];
            [messageShared dnSetObject:[[message sentTimestamp] donkyDateForServer] forKey:DCMOriginalMessageSentTimestamp];
            [messageShared dnSetObject:[message contextItems] forKey:DCMContextItems];
            [messageShared dnSetObject:[[NSDate date] donkyDateForServer] forKey:DCMSharedTimestamp];

            DNClientNotification *messageSharedNotification = [[DNClientNotification alloc] initWithType:DCMMessageShared data:messageShared acknowledgementData:nil];
            [[DNNetworkController sharedInstance] queueClientNotifications:@[messageSharedNotification]];
        }
    });
}

+ (void)reportMessagesDeleted:(NSArray *)messages {

    __block NSMutableArray *clientNotifs = [[NSMutableArray alloc] init];
    [messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DNClientNotification *msgDeleted = [[DNClientNotification alloc] initWithType:DCMMessageDeleted data:@{@"messageId" : [obj messageID]} acknowledgementData:nil];
        [clientNotifs addObject:msgDeleted];
    }];

    if ([clientNotifs count]) {
        [[DNNetworkController sharedInstance] queueClientNotifications:clientNotifs completion:^(id data) {
            [[DNNetworkController sharedInstance] synchronise];
        }];
    }
}

+ (NSString *)shareType:(NSString *)activityType {

    if ([activityType isEqualToString:UIActivityTypePostToTwitter])
        return @"TWITTER";
    else if ([activityType isEqualToString:UIActivityTypePostToFacebook])
        return @"FACEBOOK";
    else if ([activityType isEqualToString:UIActivityTypePostToWeibo])
        return @"WEIBO";
    else if ([activityType isEqualToString:UIActivityTypeMessage])
        return @"SMS";
    else if ([activityType isEqualToString:UIActivityTypeMail])
        return @"EMAIL";
    else if ([activityType isEqualToString:UIActivityTypePrint])
        return @"PRINT";
    else if ([activityType isEqualToString:UIActivityTypeCopyToPasteboard])
        return @"PASTEBOARD";
    else if ([activityType isEqualToString:UIActivityTypeAirDrop])
        return @"AIRDROP";

    return activityType;
}

@end