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

+ (NSArray *)clientNotificationsWithTempContext:(NSManagedObjectContext *)context;

+ (NSArray *)contentNotificationsWithTempContext:(NSManagedObjectContext *)context;

+ (NSMutableDictionary *)networkClientNotifications:(NSMutableArray *)clientNotifications networkContentNotifications:(NSMutableArray *)contentNotifications tempContext:(BOOL)temp;

+ (void)saveClientNotificationsToStore:(NSArray *)array;

+ (NSMutableArray *)sendContentNotifications:(NSArray *)notifications withContext:(NSManagedObjectContext *)context;

+ (void)saveContentNotificationsToStore:(NSArray *)array;

+ (void)deleteNotifications:(NSArray *)notifications;

+ (void)clearBrokenNotifications;

+ (void)deleteNotificationForID:(NSString *)serverID;

+ (NSManagedObjectID *)notificationWithID:(NSString *)notificationID;

@end
