//
//  DPUINotification.m
//  Push UI Container
//
//  Created by Chris Watson on 15/03/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import "DPUINotification.h"
#import "DNServerNotification.h"
#import "NSDate+DNDateHelper.h"
#import "DCUILocalization+Localization.h"

@interface DPUINotification ()
@property(nonatomic, readwrite) NSDate *sentTimeStamp;
@property(nonatomic, readwrite) NSDate *messageSentTimeStamp;
@property(nonatomic, readwrite) NSDate *expiryTimeStamp;
@property(nonatomic, readwrite) NSString *body;
@property(nonatomic, readwrite) NSString *messageType;
@property(nonatomic, readwrite) NSString *senderMessageID;
@property(nonatomic, readwrite) NSString *messageID;
@property(nonatomic, readwrite) NSDictionary *contextItems;
@property(nonatomic, readwrite) NSString *senderInternalUserID;
@property(nonatomic, readwrite) NSString *avatarAssetID;
@property(nonatomic, readwrite) NSString *senderDisplayName;
@property(nonatomic, readwrite) NSArray * buttonSets;
@property(nonatomic, readwrite) NSString *serverId;
@end

@implementation DPUINotification

- (instancetype)initWithNotification:(DNServerNotification *)notification {

    self = [super init];

    if (self) {

        self.sentTimeStamp = [NSDate donkyDateFromServer:[self objectForKey:@"sentTimeStamp" inNotification:notification]];
        self.messageSentTimeStamp = [NSDate donkyDateFromServer:[self objectForKey:@"msgSentTimeStamp" inNotification:notification]];
        self.expiryTimeStamp = [NSDate donkyDateFromServer:[self objectForKey:@"expiryTimeStamp" inNotification:notification]];
        self.body = [self objectForKey:@"body" inNotification:notification];
        self.messageType = [self objectForKey:@"messageType" inNotification:notification];
        self.senderMessageID = [self objectForKey:@"senderMessageId" inNotification:notification];
        self.messageID = [self objectForKey:@"messageId" inNotification:notification];
        self.contextItems = [self objectForKey:@"contextItems" inNotification:notification];
        self.senderInternalUserID = [self objectForKey:@"senderInternalUserId" inNotification:notification];
        self.avatarAssetID = [self objectForKey:@"avatarAssetId" inNotification:notification];
        self.senderDisplayName = [self objectForKey:@"senderDisplayName" inNotification:notification];
        self.buttonSets = [self objectForKey:@"buttonSets" inNotification:notification];

        self.serverId = [notification serverNotificationID];
    }

    return self;
}

- (id)objectForKey:(NSString *)key inNotification:(DNServerNotification *) notification {
    return [notification data][key];
}

@end
