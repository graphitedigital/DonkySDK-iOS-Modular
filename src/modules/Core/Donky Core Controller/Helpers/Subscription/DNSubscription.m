//
//  DNSubscription.m
//  Core Container
//
//  Created by Chris Watson on 18/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNSubscription.h"

@interface DNSubscription ()
@property(nonatomic, readwrite) NSString *notificationType;
@property(nonatomic, readwrite) DNSubscriptionHandler handler;
@property(nonatomic, readwrite) DNSubscriptionBachHandler batchHandler;
@end

@implementation DNSubscription

- (instancetype)initWithNotificationType:(NSString *)notificationType handler:(DNSubscriptionHandler)handler {

    self = [super init];

    if (self) {
        [self setHandler:handler];
        [self setAutoAcknowledge:YES];
        [self setNotificationType:notificationType];
    }

    return self;
}

- (instancetype)initWithNotificationType:(NSString *)notificationType batchHandler:(DNSubscriptionBachHandler)batchHandler {

    self = [super init];

    if (self) {
        [self setBatchHandler:batchHandler];
        [self setAutoAcknowledge:YES];
        [self setNotificationType:notificationType];
    }

    return self;
}

@end
