//
//  DCMLogicMessageMapper.m
//  RichLogic
//
//  Created by Donky Networks on 08/08/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DCMLogicMessageMapper.h"
#import <Donky_Core_SDK/DNServerNotification.h>
#import "DNMessage.h"
#import "DCMConstants.h"
#import <Donky_Core_SDK/NSDate+DNDateHelper.h>

@implementation DCMLogicMessageMapper

+ (void)upsertServerNotification:(DNServerNotification *)serverNotification toMessage:(DNMessage *)message {

    [message setNotificationID:[serverNotification serverNotificationID]];
    [message setExpiryTimestamp:[NSDate donkyDateFromServer:[serverNotification data][DCMExpiryTimeStamp]]];
    [message setSenderDisplayName:[serverNotification data][DCMSenderDisplayName]];
    [message setExternalRef:[serverNotification data][DCMExternalRef]];
    [message setSenderMessageID:[serverNotification data][DCMSenderMessageID]];
    [message setCanReply:[serverNotification data][DCMCanReply]];
    [message setSenderExternalUserID:[serverNotification data][DCMSenderExternalUserID]];
    [message setSilentNotification:[serverNotification data][DCMSilentNotification]];
    [message setBody:[serverNotification data][DCMBody]];
    [message setSentTimestamp:[NSDate donkyDateFromServer:[serverNotification data][DCMSentTimestamp]]];
    [message setContextItems:[serverNotification data][DCMContextItems]];
    [message setSenderAccountType:[serverNotification data][DCMSenderAccountType]];
    [message setAvatarAssetID:[serverNotification data][DCMAvatarAssetID]];
    [message setMessageType:[serverNotification data][DCMMessageType]];
    [message setConversationID:[serverNotification data][DCMConversationID]];
    [message setMessageScope:[serverNotification data][DCMMessageScope]];
    [message setCanForward:[serverNotification data][DCMCanForward]];
    [message setSenderInternalUserID:[serverNotification data][DCMSenderInternalUserID]];
    [message setMessageReceivedTimestamp:[NSDate date]];
    [message setMessageID:[serverNotification data][DCMMessageID]];
    
    if ([message respondsToSelector:@selector(setExternalID:)]) {
        [message setExternalID:[serverNotification data][@"externalId"]];
    }
    
    [message setRead:@(NO)];
}

@end
