//
//  DPPushNotification.h
//  PushLogic
//
//  Created by Chris Watson on 26/01/2016.
//  Copyright © 2016 Dynmark International Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Donky_Core_SDK/DNServerNotification.h>
#import <Donky_Core_SDK/DNBlockDefinitions.h>

@interface DPPushNotification : NSObject

@property (nonatomic, readonly) NSString *body;

@property (nonatomic, readonly) NSString *senderDisplayName;

@property (nonatomic, readonly) NSString *senderAvatarID;

@property (nonatomic, readonly) NSArray *interactiveButtonSets;

@property (nonatomic, readonly) NSString *messageID;

@property (nonatomic, readonly) NSString *senderMessageID;

@property (nonatomic, readonly) NSDate *sentTimeStamp;

@property (nonatomic, readonly) NSString *senderInternalUserID;

@property (nonatomic, readonly) NSString *firstButtonLabel;

@property (nonatomic, readonly) NSString *secondButtonLabel;

@property (nonatomic, readonly) NSString *firstButtonLink;

@property (nonatomic, readonly) NSString *secondButtonLink;

- (instancetype)initWithServerNotification:(DNServerNotification *)serverNotification;

- (instancetype)initWithRemoteNotification:(NSDictionary *)userInfo;

- (void)senderAvatar:(DNCompletionBlock)completionBlock;

@end
