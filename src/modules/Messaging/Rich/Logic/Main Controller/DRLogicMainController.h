//
//  DRLogicMainController.h
//  RichPopUp
//
//  Created by Chris Watson on 13/04/2015.
//  Copyright (c) 2015 Chris Watson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DNModuleDefinition;
@class DNSubscription;

@interface DRLogicMainController : NSObject

/*!
 Singleton instance for Donky Rich Logic
 
 @return the current DNDonkyCore instance.
 */
+ (DRLogicMainController *) sharedInstance;

- (void)start;

- (void)stop;

- (void)deleteMessage:(NSString *)messageID;

- (void)markMessageAsRead:(NSString *)messageID;

- (NSArray *)filterRichMessages:(NSString *)filter;

@end
