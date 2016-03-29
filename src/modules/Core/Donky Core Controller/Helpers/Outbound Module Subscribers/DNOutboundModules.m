//
//  DNOutboundModules.m
//  Core Container
//
//  Created by Donky Networks on 17/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DNLoggingController.h"
#import "DNOutboundModules.h"
#import "DNModuleDefinition.h"
#import "DNSubscription.h"
#import "DNModuleHelper.h"

@interface DNOutboundModules ()
@property(nonatomic, strong) NSMutableDictionary *outboundModules;
@end

@implementation DNOutboundModules

- (instancetype) init {
    
    self = [super init];
    
    if (self) {
        [self setOutboundModules:[[NSMutableDictionary alloc] init]];
    }

    return self;
}

- (void)subscribeToOutboundNotifications:(DNModuleDefinition *)moduleDefinition subscriptions:(NSArray *)subscriptions {
    [subscriptions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[DNSubscription class]]) {
            DNErrorLog(@"Something has gone wrong with. Expected DNSubscription (or subclass thereof) got: %@... Bailing out", NSStringFromClass([obj class]));
        }
        else {
            DNSubscription *subscription = obj;
            [DNModuleHelper addModule:moduleDefinition toModuleList:[self outboundModules] subscription:subscription];
        }
    }];
}

- (void)unSubscribeToOutboundNotifications:(DNModuleDefinition *)moduleDefinition subscriptions:(NSArray *)subscriptions {
    [subscriptions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[DNSubscription class]]) {
            DNErrorLog(@"Something has gone wrong with. Expected DNSubscription (or subclass thereof) got: %@... Bailing out", NSStringFromClass([obj class]));
        }
        else {
            DNSubscription *subscription = obj;
            [DNModuleHelper removeModule:moduleDefinition toModuleList:[self outboundModules] subscription:subscription];
        }
    }];
}

- (void)publishOutboundNotification:(NSString *)type data:(id)data {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray *outboundSubscribers = [[self outboundModules][type] allObjects];
        [outboundSubscribers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (![obj isKindOfClass:[DNSubscription class]]) {
                DNErrorLog(@"Something has gone wrong with. Expected DNSubscription (or subclass thereof) got: %@... Bailing out", NSStringFromClass([obj class]));
            }
            else {
                DNSubscription *subscription = obj;
                if ([subscription handler]) {
                    [subscription handler](data);
                }
            }
        }];
    });
}


@end
