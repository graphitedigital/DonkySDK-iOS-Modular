//
//  DNNotificationSubscriber.h
//  Donky Network SDK Container
//
//  Created by Chris Watson on 06/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DNServerNotification.h"
#import "DNModuleDefinition.h"

@interface DNNotificationSubscriber : NSObject

- (instancetype) init;

- (void)subscribeToDonkyNotifications:(DNModuleDefinition *)moduleDefinition subscriptions:(NSArray *)subscriptions;

- (void)subscribeToNotifications:(DNModuleDefinition *)moduleDefinition subscriptions:(NSArray *)subscriptions;

- (void)notificationsReceived:(NSDictionary *)dictionary;

- (void)processNotifications:(NSArray *)notifications subscribers:(NSArray *)subscribers;

- (void)unSubscribeToDonkyNotifications:(DNModuleDefinition *)moduleDefinition subscriptions:(NSArray *)subscriptions;

- (void)unSubscribeToNotifications:(DNModuleDefinition *)moduleDefinition subscriptions:(NSArray *)subscriptions;

@end
