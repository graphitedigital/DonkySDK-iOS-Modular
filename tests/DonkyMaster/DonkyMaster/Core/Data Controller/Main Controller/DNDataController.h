//
//  DNDataController.h
//  NAAS Core SDK Container
//
//  Created by Chris Watson on 16/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DNServerNotification.h"
#import "DNUserDetails.h"
#import "DNNotification.h"
#import "DNClientNotification.h"
#import "DNDeviceUser.h"

@class DNRichMessage;

@interface DNDataController : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *mainContext;

@property (nonatomic, strong, readonly) NSManagedObjectContext *temporaryContext;

@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (DNDataController *)sharedInstance;

- (void)saveAllData;

- (DNUserDetails *)currentDeviceUser;

- (void)saveUserDetails:(DNUserDetails *)details;

- (DNDeviceUser *)newDevice;

- (NSArray *)clientNotificationsWithTempContext:(BOOL)tempContext;

- (NSArray *)contentNotificationsInTempContext:(BOOL)tempContext;

- (NSMutableArray *)sendContentNotifications:(NSArray *)notifications;

- (void)saveClientNotificationsToStore:(NSArray *)array;

- (void)saveContentNotificationsToStore:(NSArray *)array;

- (void)deleteNotifications:(NSArray *)notifications inTempContext:(BOOL)tempContext;

- (NSMutableDictionary *)networkClientNotifications:(NSMutableArray *)clientNotifications networkContentNotifications:(NSMutableArray *)contentNotifications;

- (void)deleteNotificationForID:(NSString *)serverID withTempContext:(BOOL)temp;

- (DNNotification *)notificationWithID:(NSString *)notificationID withTempContext:(BOOL)temp;

- (NSArray *)unreadRichMessages:(BOOL)unread tempContext:(BOOL)tempContext;

- (NSArray *)allRichMessagesTempContext:(BOOL)tempContext;

- (DNRichMessage *)richMessageForID:(NSString *)messageID tempContext:(BOOL)tempContext;

- (void)deleteRichMessage:(NSString *)messageID tempContext:(BOOL)tempContext;

- (NSArray *)filterRichMessage:(NSString *)filter tempContext:(BOOL)tempContext;

@end
