//
//  DNNetworkDataHelper.h
//  DonkyMaster
//
//  Created by Chris Watson on 03/06/2015.
//  Copyright (c) 2015 Chris Watson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DNNotification.h"

@interface DNNetworkDataHelper : NSObject

+ (NSArray *)clientNotificationsWithTempContext:(BOOL)temp;

+ (NSArray *)contentNotificationsWithTempContext:(BOOL)temp;

+ (NSMutableDictionary *)networkClientNotifications:(NSMutableArray *)clientNotifications networkContentNotifications:(NSMutableArray *)contentNotifications tempContext:(BOOL)temp;

+ (void)saveClientNotificationsToStore:(NSArray *)array;

+ (NSMutableArray *)sendContentNotifications:(NSArray *)notifications withContext:(NSManagedObjectContext *)context;

+ (void)saveContentNotificationsToStore:(NSArray *)array;

+ (void)deleteNotifications:(NSArray *)notifications tempContext:(BOOL)temp;

+ (void)clearBrokenNotificationsWithTempContext:(BOOL)temp;

+ (void)deleteNotificationForID:(NSString *)serverID withTempContext:(BOOL)temp;

+ (DNNotification *)notificationWithID:(NSString *)notificationID withTempContext:(BOOL)temp;

@end
