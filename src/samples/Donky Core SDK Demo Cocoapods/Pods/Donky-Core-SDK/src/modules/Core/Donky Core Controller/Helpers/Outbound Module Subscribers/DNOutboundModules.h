//
//  DNOutboundModules.h
//  Core Container
//
//  Created by Donky Networks on 17/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DNModuleDefinition.h"
#import "DNSubscription.h"

@interface DNOutboundModules : NSObject

- (instancetype)init;

- (void)subscribeToOutboundNotifications:(DNModuleDefinition *)moduleDefinition subscriptions:(NSArray *)subscriptions;

- (void)publishOutboundNotification:(NSString *)type data:(id)data;

- (void)unSubscribeToOutboundNotifications:(DNModuleDefinition *)moduleDefinition subscriptions:(NSArray *)subscriptions;

@end
