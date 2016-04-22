//
//  DRLogicHelper.h
//  RichPopUp
//
//  Created by Donky Networks on 13/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DNServerNotification.h"
#import "DNRichMessage.h"
#import "DNBlockDefinitions.h"

@interface DRLogicHelper : NSObject

+ (DNRichMessage *)saveRichMessage:(DNServerNotification *)serverNotification context:(NSManagedObjectContext *)context;

+ (void)deleteRichMessage:(DNRichMessage *)richMessage;

+ (NSArray *)allUnreadRichMessages;

+ (NSArray *)allRichMessagesAscending:(BOOL)ascending;

+ (NSArray *)richMessagesWithOffset:(NSUInteger)offset limit:(NSUInteger)limit ascending:(BOOL)ascending;

+ (NSArray *)filteredRichMessage:(NSString *)filter ascendingOrder:(BOOL)ascending;

+ (DNRichMessage *)richMessageForID:(NSString *)messageID context:(NSManagedObjectContext *)context;

+ (void)markMessageAsRead:(DNRichMessage *)richMessage;

+ (void)deleteAllRichMessages:(NSArray *)richMessages;

+ (BOOL)richMessageExistsForID:(NSString *)messageID;

+ (DNRichMessage *)richMessageWithID:(NSString *)messageID;

+ (void)deleteAllExpiredMessages;

+ (void)deleteMaxLifeRichMessages;

+ (void)markMessagesAsRead:(NSArray *)messages completion:(DNCompletionBlock)completion;

+ (void)markAllRichMessagesAsRead:(DNCompletionBlock)completion;
@end
