//
//  DCUINotification.m
//  RichInbox
//
//  Created by Donky Networks on 16/06/2015.
//  Copyright © 2015 Donky Networks. All rights reserved.
//

#import "DCUINotification.h"
#import "NSDate+DNDateHelper.h"

static NSString *const DCUISentTimeStamp = @"sentTimestamp";
static NSString *const DCUIExpiryTimeStamp = @"expiryTimeStamp";
static NSString *const DCUIBody = @"body";
static NSString *const DCUIMessageType = @"messageType";
static NSString *const DCUISenderMessageID = @"senderMessageId";
static NSString *const DCUIMessageID = @"messageId";
static NSString *const DCUIContextItems = @"contextItems";
static NSString *const DCUISenderInternalUserID = @"senderInternalUserId";
static NSString *const DCUIAvatarAssetID = @"avatarAssetId";
static NSString *const DCUISenderDisplayName = @"senderDisplayName";
static NSString *const DCUIButtonSets = @"buttonSets";

@interface DCUINotification ()
@property(nonatomic, readwrite) NSDate *sentTimeStamp;
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

@implementation DCUINotification

- (instancetype)initWithNotification:(DNServerNotification *)notification {

    self = [self init];

    if (self) {

        [self setSentTimeStamp:[NSDate donkyDateFromServer:[self objectForKey:DCUISentTimeStamp inNotification:notification]]];
        [self setExpiryTimeStamp:[NSDate donkyDateFromServer:[self objectForKey:DCUIExpiryTimeStamp inNotification:notification]]];
        [self setBody:[self objectForKey:DCUIBody inNotification:notification]];
        [self setMessageType:[self objectForKey:DCUIMessageType inNotification:notification]];
        [self setSenderMessageID:[self objectForKey:DCUISenderMessageID inNotification:notification]];
        [self setMessageID:[self objectForKey:DCUIMessageID inNotification:notification]];
        [self setContextItems:[self objectForKey:DCUIContextItems inNotification:notification]];
        [self setSenderInternalUserID:[self objectForKey:DCUISenderInternalUserID inNotification:notification]];
        [self setAvatarAssetID:[self objectForKey:DCUIAvatarAssetID inNotification:notification]];
        [self setSenderDisplayName:[self objectForKey:DCUISenderDisplayName inNotification:notification]];
        [self setButtonSets:[self objectForKey:DCUIButtonSets inNotification:notification]];
        [self setServerId:[notification serverNotificationID]];

    }

    return self;
}

- (instancetype)initWithNotification:(DNServerNotification *)notification customBody:(NSString *)customBody {
    
    self = [self initWithNotification:notification];
    
    if (self) {
        
        [self setBody:customBody];
        
    }
    
    return self;
}

- (id)objectForKey:(NSString *)key inNotification:(DNServerNotification *) notification {
    return [notification data][key];
}

@end
