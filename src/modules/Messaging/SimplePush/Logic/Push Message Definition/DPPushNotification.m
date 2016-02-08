//
//  DPPushNotification.m
//  PushLogic
//
//  Created by Chris Watson on 26/01/2016.
//  Copyright © 2016 Dynmark International Ltd. All rights reserved.
//

#import "DPPushNotification.h"
#import "DNAssetController.h"
#import "DNErrorController.h"
#import "DNLoggingController.h"
#import "NSDate+DNDateHelper.h"
#import "DCMConstants.h"
#import "DNAccountController.h"
#import "DNNetworkController.h"

@interface DPPushNotification ()
@property (nonatomic, readwrite) NSString *body;
@property (nonatomic, readwrite) NSString *senderDisplayName;
@property (nonatomic, readwrite) NSString *senderAvatarID;
@property (nonatomic, readwrite) NSArray *interactiveButtonSets;
@property (nonatomic, readwrite) NSString *messageID;
@property (nonatomic, readwrite) NSString *senderMessageID;
@property (nonatomic, readwrite) NSDate *sentTimeStamp;
@property (nonatomic, readwrite) NSString *senderInternalUserID;
@end

@implementation DPPushNotification

- (instancetype)initWithServerNotification:(DNServerNotification *)serverNotification {
    
    self = [super init];

    if (self) {

        NSDictionary *pushMessage = [serverNotification data];

        [self setBody:pushMessage[DCMBody]];
        [self setSenderDisplayName:pushMessage[DCMSenderDisplayName]];
        [self setSenderAvatarID:pushMessage[DCMAvatarAssetID]];

        [self setInteractiveButtonSets:pushMessage[kDCMButtonSets]];
        [self setMessageID:pushMessage[DCMMessageID]];
        [self setSenderMessageID:pushMessage[DCMSenderMessageID]];
        [self setSentTimeStamp:[NSDate donkyDateFromServer:pushMessage[DCMSentTimestamp]]];
        [self setSenderInternalUserID:pushMessage[DCMSenderInternalUserID]];

    }
    
    return self;
}

- (instancetype)initWithRemoteNotification:(NSDictionary *)userInfo {

    self = [super init];

    if (self) {

        NSArray *arguments = userInfo[@"aps"][@"alert"][@"loc-args"];

        [self setBody:[arguments lastObject]];
        [self setSenderDisplayName:[arguments firstObject]];

    }

    return self;
}

- (void)senderAvatar:(DNCompletionBlock)completionBlock {

    if (![self senderAvatarID]) {
        DNErrorLog(@"No avatar ID so cannot get avatar.");
        if (completionBlock) {
            completionBlock([DNErrorController errorCode:0000 userInfo:@{@"FailureReason" : @"No sender avatar ID, cannot get image."}]);
        }

        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        UIImage *image = [DNAssetController avatarAssetForID:[self senderAvatarID]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(image);
            }
        });
    });
}

@end
