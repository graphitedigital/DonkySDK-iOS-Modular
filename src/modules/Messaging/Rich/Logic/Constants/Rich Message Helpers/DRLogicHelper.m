//
//  DRLogicHelper.m
//  RichPopUp
//
//  Created by Donky Networks on 13/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DRLogicHelper.h"
#import <Donky_Core_SDK/DNDataController.h>
#import <Donky_Core_SDK/DNLoggingController.h>
#import <Donky_CommonMessaging_Logic/DCMConstants.h>
#import <Donky_Core_SDK/NSManagedObject+DNHelper.h>
#import <Donky_CommonMessaging_Logic/DCMMainController.h>
#import <Donky_Core_SDK/DNDonkyCore.h>
#import <Donky_RichMessage_Logic/DRConstants.h>
#import <Donky_RichMessage_Logic/DNRichMessage+DNRichMessageHelper.h>
#import <Donky_CommonMessaging_Logic/DCMLogicMessageMapper.h>

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
        NSManagedObjectContext *context = nil;
        if ([NSThread currentThread] == [NSThread mainThread]) {
            context = [[DNDataController sharedInstance] mainContext];
        }
        else {
            context = [DNDataController temporaryContext];
        }

        [DCMMainController reportMessagesDeleted:@[richMessage]];

        [context deleteObject:richMessage];

        [[DNDataController sharedInstance] saveAllData];
    }
}

+ (NSArray *)allUnreadRichMessages {
    NSManagedObjectContext *context = nil;
    if ([NSThread currentThread] == [NSThread mainThread]) {
        context = [[DNDataController sharedInstance] mainContext];
    }
    else {
        context = [DNDataController temporaryContext];
    }
    return [DNRichMessage fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"read == NO"]
                                   sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:DRMessageIDSortDescriptor ascending:YES]]
                                       withContext:context];
}

+ (NSArray *)allRichMessagesAscending:(BOOL)ascending {
    NSManagedObjectContext *context = nil;
    if ([NSThread currentThread] == [NSThread mainThread]) {
        context = [[DNDataController sharedInstance] mainContext];
    }
    else {
        context = [DNDataController temporaryContext];
    }
    return [DNRichMessage fetchObjectsWithPredicate:nil
                                    sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:DRMessageTimeStampDescriptor ascending:ascending]]
                                        withContext:context];
}

+ (NSArray *)richMessagesWithOffset:(NSUInteger)offset limit:(NSUInteger)limit ascending:(BOOL)ascending {
    NSManagedObjectContext *context = nil;
    if ([NSThread currentThread] == [NSThread mainThread]) {
        context = [[DNDataController sharedInstance] mainContext];
    }
    else {
        context = [DNDataController temporaryContext];
    }
    return [DNRichMessage fetchObjectsWithOffset:offset
                                           limit:limit
                                  sortDescriptor:@[[NSSortDescriptor sortDescriptorWithKey:DRMessageTimeStampDescriptor ascending:ascending]]
                                     withContext:context];
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

+ (void)markAllRichMessagesAsRead:(DNCompletionBlock)completion {
    NSArray *allRichMessages = [DRLogicHelper allUnreadRichMessages];
    [DRLogicHelper markMessagesAsRead:allRichMessages completion:completion];
}

+ (void)markMessagesAsRead:(NSArray *)messages completion:(DNCompletionBlock)completion {
    [DCMMainController markAllMessagesAsRead:messages completion:completion];
}

+ (void)deleteAllRichMessages:(NSArray *)richMessages {
    NSManagedObjectContext *context = nil;
    if ([NSThread currentThread] == [NSThread mainThread]) {
        context = [[DNDataController sharedInstance] mainContext];
    }
    else {
        context = [DNDataController temporaryContext];
    }
    __block NSInteger unreadCount = 0;
    [richMessages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DNRichMessage *message = obj;
        //Reduce app badge count:
        if (![[message read] boolValue]) {
          unreadCount += 1;
        }
        [context deleteObject:message];
    }];


    [DCMMainController reportMessagesDeleted:richMessages];

    if (unreadCount > 0) {
        DNLocalEvent *localEvent = [[DNLocalEvent alloc] initWithEventType:kDRichMessageBadgeCount
                                                                 publisher:NSStringFromClass([self class])
                                                                 timeStamp:[NSDate date]
                                                                      data:@(unreadCount)];
        [[DNDonkyCore sharedInstance] publishEvent:localEvent];
    }

    [[DNDataController sharedInstance] saveContext:context];
}

+ (BOOL)richMessageExistsForID:(NSString *)messageID {
    NSManagedObjectContext *context = nil;
    if ([NSThread currentThread] == [NSThread mainThread]) {
        context = [[DNDataController sharedInstance] mainContext];
    }
    else {
        context = [DNDataController temporaryContext];
    }
    return [DNRichMessage fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"messageID == %@ || notificationID == %@", messageID, messageID]
                                             withContext:context includesPendingChanges:YES] != nil;
}

+ (DNRichMessage *)richMessageWithID:(NSString *)messageID {
    NSManagedObjectContext *context = nil;
    if ([NSThread currentThread] == [NSThread mainThread]) {
        context = [[DNDataController sharedInstance] mainContext];
    }
    else {
        context = [DNDataController temporaryContext];
    }

    __block DNRichMessage *richMessage = nil;
    [context performBlockAndWait:^{
        richMessage = [DNRichMessage fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"messageID == %@ || notificationID == %@", messageID, messageID]
                                                        withContext:context includesPendingChanges:YES];
    }];

    return richMessage;
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
