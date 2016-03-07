//
//  DNNetworkDataHelper.h
//  DonkyMaster
//
//  Created by Donky Networks on 03/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DNNotification.h"

@interface DNNetworkDataHelper : NSObject

+ (NSArray *)clientNotificationsWithContext:(NSManagedObjectContext *)context;

+ (void)contentNotificationsArray:(NSArray *)notifications insertObject:(BOOL)insert completion:(DNNetworkControllerSuccessBlock)completion;

+ (NSArray *)contentNotificationsWithContext:(NSManagedObjectContext *)context;

+ (NSMutableDictionary *)networkClientNotifications:(NSMutableArray *)clientNotifications networkContentNotifications:(NSMutableArray *)contentNotifications tempContext:(BOOL)temp;

+ (void)saveClientNotificationsToStore:(NSArray *)array completion:(DNCompletionBlock)completionBlock;

+ (void)saveContentNotificationsToStore:(NSArray *)notifications completion:(DNCompletionBlock)completionBlock;

+ (void)deleteNotifications:(NSArray *)notifications completion:(DNCompletionBlock)completionBlock;

+ (void)clearBrokenNotifications;

+ (void)deleteNotificationForID:(NSString *)serverID;

+ (NSManagedObjectID *)notificationWithID:(NSString *)notificationID context:(NSManagedObjectContext *)context;

@end
