//
//  DCMMainController.m
//  Common Messaging
//
//  Created by Chris Watson on 07/04/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import "DCMMainController.h"
#import "DNClientNotification.h"
#import "DNNetworkController.h"
#import "NSMutableDictionary+DNDictionary.h"
#import "NSDate+DNDateHelper.h"
#import "DNDataController.h"
#import "DNRichMessage.h"
#import "DCMConstants.h"

static NSString *const DCMDelivered = @"delivered";
static NSString *const DCMResult = @"result";
static NSString *const DCMMessageReceived = @"MessageReceived";
static NSString *const DCMType = @"type";
static NSString *const DCMReceivedExpired = @"receivedExpired";
static NSString *const DCMMainMessageType = @"messageType";
static NSString *const DCMMessageRead = @"MessageRead";

@implementation DCMMainController

+ (void)markMessageAsReceived:(DNServerNotification *)notification {
    
    NSDictionary *notificationData = [notification data];
    
    NSMutableDictionary *messageReceived = [[NSMutableDictionary alloc] init];
    
    BOOL messageExpired = [[NSDate donkyDateFromServer:notificationData[DCMExpiryTimeStamp]] donkyHasDateExpired];

    [messageReceived dnSetObject:DCMMessageReceived forKey:DCMType];
    [messageReceived dnSetObject:notificationData[DCMSenderInternalUserID] forKey:DCMSenderInternalUserID];
    [messageReceived dnSetObject:notificationData[DCMMessageID] forKey:DCMMessageID];
    [messageReceived dnSetObject:notificationData[DCMSenderMessageID] forKey:DCMSenderMessageID];
    [messageReceived dnSetObject:messageExpired ? @"true" : @"false" forKey:DCMReceivedExpired];
    [messageReceived dnSetObject:notificationData[DCMMainMessageType] forKey:DCMMessageType];
    [messageReceived dnSetObject:notificationData[DCMMessageScope] forKey:DCMMessageScope];
    [messageReceived dnSetObject:notificationData[DCMSentTimestamp] forKey:DCMSentTimestamp];
    [messageReceived dnSetObject:notificationData[DCMContextItems] forKey:DCMContextItems];
    
    DNClientNotification *msgReceived = [[DNClientNotification alloc] initWithType:DCMMessageReceived data:messageReceived acknowledgementData:notification];
    [[msgReceived acknowledgementDetails] dnSetObject:DCMDelivered forKey:DCMResult];

    [[DNNetworkController sharedInstance] queueClientNotifications:@[msgReceived]];

}

+ (void)markMessageAsRead:(NSString *)messageID {

    DNRichMessage *message = [[DNDataController sharedInstance] richMessageForID:messageID tempContext:YES];

    if (!message) {
        return;
    }

    [message setRead:@(YES)];

    NSMutableDictionary *messageRead = [[NSMutableDictionary alloc] init];

    [messageRead dnSetObject:[message senderInternalUserID] forKey:DCMSenderInternalUserID];
    [messageRead dnSetObject:[message messageID] forKey:DCMMessageID];
    [messageRead dnSetObject:[message senderMessageID] forKey:DCMSenderMessageID];
    [messageRead dnSetObject:[message messageType] forKey:DCMMessageType];
    [messageRead dnSetObject:[message messageScope] forKey:DCMMessageScope];
    [messageRead dnSetObject:[[message sentTimestamp] donkyDateForServer] forKey:DCMSentTimestamp];
    [messageRead dnSetObject:[message contextItems] forKey:DCMContextItems];

    NSTimeInterval timeToRead = [[NSDate date] timeIntervalSinceDate:[message messageReceivedTimestamp]];
    [messageRead dnSetObject:isnan(timeToRead) ? @(0) : @(timeToRead) forKey:@"timeToReadSeconds"];

    DNClientNotification *messageReadNotification = [[DNClientNotification alloc] initWithType:DCMMessageRead data:messageRead acknowledgementData:nil];
    [[DNNetworkController sharedInstance] queueClientNotifications:@[messageReadNotification]];
}

@end