//
//  DPUINotification.h
//  Push UI Container
//
//  Created by Chris Watson on 15/03/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DNServerNotification;

@interface DPUINotification : NSObject

@property(nonatomic, readonly) NSDate *sentTimeStamp;

@property(nonatomic, readonly) NSDate *messageSentTimeStamp;

@property(nonatomic, readonly) NSDate *expiryTimeStamp;

@property(nonatomic, readonly) NSString *body;

@property(nonatomic, readonly) NSString *messageType;

@property(nonatomic, readonly) NSString *senderMessageID;

@property(nonatomic, readonly) NSString *messageID;

@property(nonatomic, readonly) NSDictionary *contextItems;

@property(nonatomic, readonly) NSString *senderInternalUserID;

@property(nonatomic, readonly) NSString *avatarAssetID;

@property(nonatomic, readonly) NSString *senderDisplayName;

@property(nonatomic, readonly) NSArray * buttonSets;

@property(nonatomic, readonly) NSString *serverId;

- (instancetype)initWithNotification:(DNServerNotification *)notification;

@end
