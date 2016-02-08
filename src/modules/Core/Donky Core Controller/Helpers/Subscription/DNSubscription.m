//
//  DNSubscription.m
//  Core Container
//
//  Created by Donky Networks on 18/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DNSubscription.h"

@interface DNSubscription ()
@property(nonatomic, readwrite) NSString *notificationType;
@property(nonatomic, readwrite) DNSubscriptionHandler handler;
@property(nonatomic, readwrite) DNSubscriptionBatchHandler batchHandler;
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

- (instancetype)initWithNotificationType:(NSString *)notificationType batchHandler:(DNSubscriptionBatchHandler)batchHandler {

    self = [super init];

    if (self) {
        [self setBatchHandler:batchHandler];
        [self setAutoAcknowledge:YES];
        [self setNotificationType:notificationType];
    }

    return self;
}

@end
