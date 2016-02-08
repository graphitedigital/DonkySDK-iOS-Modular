//
//  DNEventSubscriber.m
//  Core Container
//
//  Created by Donky Networks on 17/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DNEventSubscriber.h"
#import "DNLoggingController.h"
#import "DNLocalEvent.h"
#import "DNModuleHelper.h"
#import "DNConstants.h"

@interface DNEventSubscriber ()
@property(nonatomic, strong) NSMutableDictionary *eventListeners;
@end

@implementation DNEventSubscriber

- (instancetype) init {typedef void (^DNLocalEventHandler) (DNLocalEvent * event);

    self = [super init];
    if (self) {
        [self setEventListeners:[[NSMutableDictionary alloc] init]];
    }

    return self;
}

- (void)subscribeToLocalEvent:(NSString *)eventType handler:(DNLocalEventHandler)handler {
    
    if (!handler || [handler isKindOfClass:[DNLocalEvent class]]) {
        DNErrorLog(@"Event handler is nil or not of class DNLocalEvent. Check input...");
        return;
    }
    
    if (![[[self eventListeners] allKeys] containsObject:eventType]) {
        ([self eventListeners])[eventType] = [[NSMutableArray alloc] init];
    }
    if (![[self eventListeners][eventType] containsObject:handler]) {
        [[self eventListeners][eventType] addObject:handler];
    }
}

- (void)unSubscribeToLocalEvent:(NSString *)eventType handler:(DNLocalEventHandler)handler {
    
    if (!handler || [handler isKindOfClass:[DNLocalEvent class]]) {
        DNErrorLog(@"Event handler is nil or not of class DNLocalEvent. Check input...");
        return;
    }

    if (![[[self eventListeners] allKeys] containsObject:eventType]) {
        ([self eventListeners])[eventType] = [[NSMutableArray alloc] init];
    }
    if ([[self eventListeners][eventType] containsObject:handler]) {
        [[self eventListeners][eventType] removeObject:handler];
    }
}

- (void)publishEvent:(DNLocalEvent *)event {
    if (![event isKindOfClass:[DNLocalEvent class]]) {
        DNErrorLog(@"Error, trying to publish an event without using DNLocalEvent");
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray *events = [self eventListeners][[event eventType]];
        [events enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            DNLocalEventHandler handler = obj;
            if (handler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(event);
                });
            }
        }];

        if (![events count] && ![[event eventType] isEqualToString:kDNDonkyLogEvent]) { // We don't want to log out Log events otherwise we will get stuck in an infinite loop
            DNInfoLog(@"No listeners for event: %@", [event eventType]);
        }
    });
}

@end
