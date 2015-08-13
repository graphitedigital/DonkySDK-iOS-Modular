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

+ (NSArray *)clientNotificationsWithTempContext:(BOOL)tempContext;

+ (NSArray *)contentNotificationsInTempContext:(BOOL)tempContext;

+ (NSMutableDictionary *)networkClientNotifications:(NSMutableArray *)clientNotifications networkContentNotifications:(NSMutableArray *)contentNotifications;

+ (void)saveClientNotificationsToStore:(NSArray *)array;

+ (NSMutableArray *)sendContentNotifications:(NSArray *)notifications;

+ (void)saveContentNotificationsToStore:(NSArray *)array;

+ (void)deleteNotifications:(NSArray *)notifications inTempContext:(BOOL)tempContext;

+ (void)clearBrokenNotificationsWithTempContext:(BOOL)tempContext;

+ (void)deleteNotificationForID:(NSString *)serverID withTempContext:(BOOL)temp;

+ (DNNotification *)notificationWithID:(NSString *)notificationID withTempContext:(BOOL)temp;

@end
