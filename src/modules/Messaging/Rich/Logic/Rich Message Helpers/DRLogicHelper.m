//
//  DRLogicHelper.m
//  RichPopUp
//
//  Created by Chris Watson on 13/04/2015.
//  Copyright (c) 2015 Chris Watson. All rights reserved.
//

#import "DRLogicHelper.h"
#import "DNServerNotification.h"
#import "DNRichMessage.h"
#import "DNDataController.h"
#import "NSDate+DNDateHelper.h"
#import "DNLoggingController.h"
#import "DCMConstants.h"

@implementation DRLogicHelper

+ (DNRichMessage *)saveRichMessage:(DNServerNotification *)serverNotification {

    @try {
        DNRichMessage *richMessage = [[DNDataController sharedInstance] richMessageForID:[serverNotification data][DCMMessageID] tempContext:YES];
        
        [richMessage setExpiryTimestamp:[NSDate donkyDateFromServer:[serverNotification data][DCMExpiryTimeStamp]]];
        [richMessage setSenderDisplayName:[serverNotification data][DCMSenderDisplayName]];
        [richMessage setExternalRef:[serverNotification data][DCMExternalRef]];
        [richMessage setExpiredBody:[serverNotification data][DCMExpireBody]];
        [richMessage setSenderMessageID:[serverNotification data][DCMSenderMessageID]];
        [richMessage setCanShare:[serverNotification data][DCMCanShare]];
        [richMessage setCanReply:[serverNotification data][DCMCanReply]];
        [richMessage setSenderExternalUserID:[serverNotification data][DCMSenderExternalUserID]];
        [richMessage setSilentNotification:[serverNotification data][DCMSilentNotification]];
        [richMessage setBody:[serverNotification data][DCMBody]];
        [richMessage setSentTimestamp:[NSDate donkyDateFromServer:[serverNotification data][DCMSentTimestamp]]];
        [richMessage setContextItems:[serverNotification data][DCMContextItems]];
        [richMessage setSenderAccountType:[serverNotification data][DCMSenderAccountType]];
        [richMessage setAvatarAssetID:[serverNotification data][DCMAvatarAssetID]];
        [richMessage setMessageType:[serverNotification data][DCMMessageType]];
        [richMessage setConversationID:[serverNotification data][DCMConversationID]];
        [richMessage setMessageScope:[serverNotification data][DCMMessageScope]];
        [richMessage setCanForward:[serverNotification data][DCMCanForward]];
        [richMessage setMessageDescription:[serverNotification data][DCMDescription]];
        [richMessage setTitle:[serverNotification data][DCMDescription]];
        [richMessage setSenderInternalUserID:[serverNotification data][DCMSenderInternalUserID]];
        [richMessage setMessageReceivedTimestamp:[NSDate date]];
        
        [[DNDataController sharedInstance] saveAllData];
        
            return richMessage;

    }
    @catch (NSException *exception) {
        DNErrorLog(@"Fatal exception : %@. Reporting and continuing...", [exception description]);
        [DNLoggingController submitLogToDonkyNetworkSuccess:nil failure:nil];
    }

    return nil;
}

+ (void)deleteRichMessage:(NSString *)messageID {
    [[DNDataController sharedInstance] deleteRichMessage:messageID tempContext:NO];
    [[DNDataController sharedInstance] saveAllData];
}

+ (NSArray *)allUnreadRichMessages {
    return [[DNDataController sharedInstance] unreadRichMessages:YES tempContext:YES];
}

+ (NSArray *)allRichMessages {
    return [[DNDataController sharedInstance] unreadRichMessages:NO tempContext:YES];
}

+ (NSArray *)filteredRichMessage:(NSString *)filter tempContext:(BOOL)context {
    return [[DNDataController sharedInstance] filterRichMessage:filter tempContext:context];
}

@end
