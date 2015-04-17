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
@end

@implementation DNSubscription

- (instancetype)initWithNotificationType:(NSString *)notificationType handler:(DNSubscriptionHandler)handler {

    self = [super init];

    if (self) {
        self.handler = handler;
        self.autoAcknowledge = YES;
        self.notificationType = notificationType;
    }

    return self;
}

@end
