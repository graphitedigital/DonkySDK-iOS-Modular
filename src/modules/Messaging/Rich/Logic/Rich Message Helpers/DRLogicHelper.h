//
//  DRLogicHelper.h
//  RichPopUp
//
//  Created by Chris Watson on 13/04/2015.
//  Copyright (c) 2015 Chris Watson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DNServerNotification;
@class DNRichMessage;

@interface DRLogicHelper : NSObject

+ (DNRichMessage *)saveRichMessage:(DNServerNotification *)serverNotification;

+ (void)deleteRichMessage:(NSString *)messageID;

+ (NSArray *)allUnreadRichMessages;

+ (NSArray *)allRichMessages;

+ (NSArray *)filteredRichMessage:(NSString *)filter tempContext:(BOOL)context;

@end
