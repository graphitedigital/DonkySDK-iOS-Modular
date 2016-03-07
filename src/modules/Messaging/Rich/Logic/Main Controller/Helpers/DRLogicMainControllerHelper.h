//
//  DRLogicMainControllerHelper.h
//  RichInbox
//
//  Created by Donky Networks on 23/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNSubscription.h"
#import "DNBlockDefinitions.h"

@interface DRLogicMainControllerHelper : NSObject

+ (DNSubscriptionBatchHandler)richMessageHandler;

+ (void)richMessageNotificationReceived:(NSArray *)notifications backgroundNotifications:(NSMutableArray *)backgroundNotifications;

+ (DNSubscriptionBatchHandler)richMessageReadHandler;

+ (DNSubscriptionBatchHandler)richMessageDeleted;

@end
