//
//  DRLogicHelper.m
//  RichPopUp
//
//  Created by Donky Networks on 13/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DRLogicHelper.h"
#import "DNDataController.h"
#import "DNLoggingController.h"
#import "DCMConstants.h"
#import "NSManagedObject+DNHelper.h"
#import "DCMMainController.h"
#import "DNDonkyCore.h"
#import "DRConstants.h"
#import "DNRichMessage+DNRichMessageHelper.h"
#import "DCMLogicMessageMapper.h"

static NSString *const DRMessageIDSortDescriptor = @"messageID";

static NSString *const DRMessageTimeStampDescriptor = @"sentTimestamp";

@implementation DRLogicHelper

+ (DNRichMessage *)saveRichMessage:(DNServerNotification *)serverNotification context:(NSManagedObjectContext *)context {

    @try {

        DNRichMessage *richMessage = [DRLogicHelper richMessageForID:[serverNotification data][DCMMessageID] context:context];
        
        [DCMLogicMessageMapper upsertServerNotification:serverNotification toMessage:richMessage];
       
        [richMessage setExpiredBody:[serverNotification data][DCMExpireBody]];
        [richMessage setCanShare:[serverNotification data][DCMCanShare]];
        [richMessage setMessageDescription:[serverNotification data][DCMDescription]];
        [richMessage setTitle:[serverNotification data][DCMDescription]];
        [richMessage setSenderInternalUserID:[serverNotification data][DCMSenderInternalUserID]];
        [richMessage setUrlToShare:[serverNotification data][DCMUrlToShare]];
 
        return richMessage;
    }
    @catch (NSException *exception) {
        DNErrorLog(@"Fatal exception : %@. Reporting and continuing...", [exception description]);
        [DNLoggingController submitLogToDonkyNetworkSuccess:nil failure:nil];
    }

    return nil;
}

+ (void)deleteRichMessage:(DNRichMessage *)richMessage {
    if (richMessage) {
        [[[DNDataController sharedInstance] mainContext] deleteObject:richMessage];
        [[DNDataController sharedInstance] saveAllData];
    }
}

+ (NSArray *)allUnreadRichMessages {
    return [DNRichMessage fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"read == NO"]
                                   sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:DRMessageIDSortDescriptor ascending:YES]]
                                       withContext:[[DNDataController sharedInstance] mainContext]];
}

+ (NSArray *)allRichMessagesAscending:(BOOL)ascending {
    return [DNRichMessage fetchObjectsWithPredicate:nil
                                    sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:DRMessageTimeStampDescriptor ascending:ascending]]
                                        withContext:[[DNDataController sharedInstance] mainContext]];
}

+ (NSArray *)richMessagesWithOffset:(NSUInteger)offset limit:(NSUInteger)limit ascending:(BOOL)ascending {
    return [DNRichMessage fetchObjectsWithOffset:offset
                                           limit:limit
                                  sortDescriptor:@[[NSSortDescriptor sortDescriptorWithKey:DRMessageTimeStampDescriptor ascending:ascending]]
                                     withContext:[[DNDataController sharedInstance] mainContext]];
}

+ (NSArray *)filteredRichMessage:(NSString *)filter ascendingOrder:(BOOL)ascending {
    if (!filter) {
        return nil;
    }
    
    NSManagedObjectContext *context = [[DNDataController sharedInstance] mainContext];

    return [DNRichMessage fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"messageDescription CONTAINS[cd] %@ || senderDisplayName CONTAINS[cd] %@", filter, filter]
                                    sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:DRMessageTimeStampDescriptor ascending:ascending]]
                                        withContext:context];
}

+ (DNRichMessage *)richMessageForID:(NSString *)messageID context:(NSManagedObjectContext *)context {
    DNRichMessage *message = [DNRichMessage fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"messageID == %@ || notificationID == %@", messageID, messageID]
                                                               withContext:context ? : [[DNDataController sharedInstance] mainContext] includesPendingChanges:YES];
    if (!message) {
        message = [DNRichMessage insertNewInstanceWithContext:context ? : [[DNDataController sharedInstance] mainContext]];
        [message setMessageID:messageID];
        [message setRead:@(NO)];
    }

    return message;
}

+ (void)markMessageAsRead:(DNRichMessage *)richMessage {
    if (richMessage && ![[richMessage read] boolValue]) {
        [DCMMainController markMessageAsRead:richMessage];

        DNLocalEvent *messageRead = [[DNLocalEvent alloc] initWithEventType:kDRichMessageReadEvent
                                                                  publisher:NSStringFromClass([self class])
                                                                  timeStamp:[NSDate date]
                                                                       data:richMessage];
        [[DNDonkyCore sharedInstance] publishEvent:messageRead];

        DNLocalEvent *changeBadgeEvent = [[DNLocalEvent alloc] initWithEventType:kDRichMessageBadgeCount
                                                                           publisher:NSStringFromClass([self class])
                                                                           timeStamp:[NSDate date]
                                                                                data:@(1)];
        [[DNDonkyCore sharedInstance] publishEvent:changeBadgeEvent];

        [[DNDataController sharedInstance] saveAllData];
    }
}

+ (void)deleteAllRichMessages:(NSArray *)richMessages {
    __block NSInteger unreadCount = 0;
    [richMessages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DNRichMessage *message = obj;
        //Reduce app badge count:
        if (![[message read] boolValue]) {
          unreadCount += 1;
        }
        [[[DNDataController sharedInstance] mainContext] deleteObject:message];
    }];

    if (unreadCount > 0) {
        DNLocalEvent *localEvent = [[DNLocalEvent alloc] initWithEventType:kDRichMessageBadgeCount publisher:NSStringFromClass([self class]) timeStamp:[NSDate date] data:@(unreadCount)];
        [[DNDonkyCore sharedInstance] publishEvent:localEvent];
    }

    [[DNDataController sharedInstance] saveAllData];
}

+ (BOOL)richMessageExistsForID:(NSString *)messageID {
    return [DNRichMessage fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"messageID == %@ || notificationID == %@", messageID, messageID]
                                                      withContext:[[DNDataController sharedInstance] mainContext] includesPendingChanges:YES] != nil;
}

+ (DNRichMessage *)richMessageWithID:(NSString *)messageID {
    return [DNRichMessage fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"messageID == %@ || notificationID == %@", messageID, messageID]
                                             withContext:[[DNDataController sharedInstance] mainContext] includesPendingChanges:YES];
}

+ (void)deleteAllExpiredMessages {

    NSArray *allMessages = [DRLogicHelper allRichMessagesAscending:YES];

    NSMutableArray *expiredMessages = [[NSMutableArray alloc] init];

    [allMessages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DNRichMessage *message = obj;
        if ([message richHasCompletelyExpired]) {
            [expiredMessages addObject:message];
        }
    }];

    [DRLogicHelper deleteAllRichMessages:expiredMessages];
}

+ (void)deleteMaxLifeRichMessages {
    NSArray *allMessages = [DRLogicHelper allRichMessagesAscending:YES];

    NSMutableArray *expiredMessages = [[NSMutableArray alloc] init];

    [allMessages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DNRichMessage *message = obj;
        if ([message richHasReachedExpiration]) {
            [expiredMessages addObject:message];
        }
    }];

    [DRLogicHelper deleteAllRichMessages:expiredMessages];
}

@end
