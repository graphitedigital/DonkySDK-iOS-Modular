//
//  DRLogicHelper.h
//  RichPopUp
//
//  Created by Chris Watson on 13/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNServerNotification.h"
#import "DNRichMessage.h"

@interface DRLogicHelper : NSObject

+ (DNRichMessage *)saveRichMessage:(DNServerNotification *)serverNotification;

+ (void)deleteRichMessage:(DNRichMessage *)richMessage;

+ (NSArray *)allUnreadRichMessages;

+ (NSArray *)allRichMessagesAscending:(BOOL)ascending;

+ (NSArray *)richMessagesWithOffset:(NSUInteger)offset limit:(NSUInteger)limit ascending:(BOOL)ascending;

+ (NSArray *)filteredRichMessage:(NSString *)filter tempContext:(BOOL)tempContext ascendingOrder:(BOOL)ascending;

+ (DNRichMessage *)richMessageForID:(NSString *)messageID;

+ (void)markMessageAsRead:(DNRichMessage *)richMessage;

+ (void)deleteAllRichMessages:(NSArray *)richMessages;

+ (BOOL)richMessageExistsForID:(NSString *)messageID;

+ (DNRichMessage *)richMessageWithID:(NSString *)messageID;

+ (void)deleteAllExpiredMessages;

@end
