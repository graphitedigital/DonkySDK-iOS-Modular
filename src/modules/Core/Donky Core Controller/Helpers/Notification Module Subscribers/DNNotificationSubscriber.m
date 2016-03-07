//
//  DNNotificationSubscriber.m
//  Donky Network SDK Container
//
//  Created by Donky Networks on 06/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DNNotificationSubscriber.h"
#import "DNLoggingController.h"
#import "DNAccountController.h"
#import "DNSubscription.h"
#import "DNModuleHelper.h"
#import "DNNetworkController.h"
#import "NSMutableDictionary+DNDictionary.h"
#import "DNClientNotification.h"
#import "DNDataController.h"
#import "DNConstants.h"
#import "DNDonkyCore.h"
#import "DNContentNotification.h"

static NSString *const DNNotificationCustom = @"Custom";
static NSString *const DNNotificationCustomType = @"customType";
static NSString *const DNDelivered = @"delivered";
static NSString *const DNDeliveredNoSubscription = @"DeliveredNoSubscription";
static NSString *const DNResult = @"result";

@interface DNNotificationSubscriber ()
@property(nonatomic, strong) NSMutableDictionary *donkyNotificationSubscribers;
@property(nonatomic, strong) NSMutableDictionary *customNotificationSubscribers;
@end

@implementation DNNotificationSubscriber

- (instancetype)init {

    self = [super init];

    if (self) {
        [self setDonkyNotificationSubscribers:[[NSMutableDictionary alloc] init]];
        [self setCustomNotificationSubscribers:[[NSMutableDictionary alloc] init]];
    }

    return self;
}

- (void)subscribeToDonkyNotifications:(DNModuleDefinition *)moduleDefinition subscriptions:(NSArray *)subscriptions {
    [subscriptions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[DNSubscription class]]) {
            DNErrorLog(@"Something has gone wrong with. Expected DNSubscription (or subclass thereof) got: %@... Bailing out", NSStringFromClass([obj class]));
        }
        else {
            DNSubscription *subscription = obj;
            [DNModuleHelper addModule:moduleDefinition toModuleList:[self donkyNotificationSubscribers] subscription:subscription];
        }
    }];
}

- (void)unSubscribeToDonkyNotifications:(DNModuleDefinition *)moduleDefinition subscriptions:(NSArray *)subscriptions {
    [subscriptions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[DNSubscription class]]) {
            DNErrorLog(@"Something has gone wrong with. Expected DNSubscription (or subclass thereof) got: %@... Bailing out", NSStringFromClass([obj class]));
        }
        else {
            DNSubscription *subscription = obj;
            [DNModuleHelper removeModule:moduleDefinition toModuleList:[self donkyNotificationSubscribers] subscription:subscription];
        }
    }];
}

- (void)subscribeToNotifications:(DNModuleDefinition *)moduleDefinition subscriptions:(NSArray *)subscriptions {
    [subscriptions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[DNSubscription class]]) {
            DNErrorLog(@"Something has gone wrong with. Expected DNSubscription (or subclass thereof) got: %@... Bailing out", NSStringFromClass([obj class]));
        }
        else {
            DNSubscription *subscription = obj;
            [subscription setAutoAcknowledge:YES];
            [DNModuleHelper addModule:moduleDefinition toModuleList:[self customNotificationSubscribers] subscription:subscription];
        }
    }];
}

- (void)unSubscribeToNotifications:(DNModuleDefinition *)moduleDefinition subscriptions:(NSArray *)subscriptions {
    [subscriptions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[DNSubscription class]]) {
            DNErrorLog(@"Something has gone wrong with. Expected DNSubscription (or subclass thereof) got: %@... Bailing out", NSStringFromClass([obj class]));
        }
        else {
            DNSubscription *subscription = obj;
            [subscription setAutoAcknowledge:YES];
            [DNModuleHelper removeModule:moduleDefinition toModuleList:[self customNotificationSubscribers] subscription:subscription];
        }
    }];
}

- (void)notificationsReceived:(NSDictionary *)dictionary {
    __block NSArray *subscribers = nil;
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqualToString:DNNotificationCustom]) {
            //Get subscriber:
            __block NSMutableArray *processedTypes = [[NSMutableArray alloc] init];
            [obj enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx2, BOOL *stop2) {
                DNServerNotification *serverNotification = obj2;
                NSString *type = [serverNotification data][DNNotificationCustomType];
                subscribers = [[self customNotificationSubscribers][type] allObjects];
                NSArray *filteredArray = [obj filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"data.customType == %@", type]];
                
                __block bool processedType = NO;
                [processedTypes enumerateObjectsUsingBlock:^(id obj3, NSUInteger idx3, BOOL *stop3) {
                    if ([obj3 isEqualToString:type]) {
                        processedType = YES;
                        *stop = YES;
                    }
                }];
                if ([filteredArray count] && !processedType) {
                    [processedTypes addObject:type];
                    [self processNotifications:filteredArray subscribers:subscribers];
                }
            }];
        }
        else {
            subscribers = [[self donkyNotificationSubscribers][key] allObjects];
            [self processNotifications:obj subscribers:subscribers];
        }
        if (!subscribers) {
            if ([key isEqualToString:kDNDonkyNotificationRichMessage]) {
                NSInteger count = [[UIApplication sharedApplication] applicationIconBadgeNumber];
                if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
                    DNInfoLog(@"Artificially increasing badge count by: %lu", (long)[obj count]);
                    count += [obj count];
                }

                DNInfoLog(@"Decreasing server badge count as no subscribers for %lu object(s) of type %@", (long)[obj count], key);
                count -= [obj count];
                DNLocalEvent *changeBadgeEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkySetBadgeCount
                                                                               publisher:NSStringFromClass([self class])
                                                                               timeStamp:[NSDate date]
                                                                                    data:@(count)];
                [[DNDonkyCore sharedInstance] publishEvent:changeBadgeEvent];
            }

            DNInfoLog(@"No subscribers for: %@", key);
            [self acknowledgeNotifications:obj hasSubscribers:NO];
        }
    }];
}

- (void)processNotifications:(NSArray *)notifications subscribers:(NSArray *)subscribers {
    __block BOOL hasAcknowledged = NO;
    [subscribers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[DNSubscription class]]) {
            DNErrorLog(@"Something has gone wrong with. Expected DNSubscription (or subclass thereof) got: %@... Bailing out", NSStringFromClass([obj class]));
        }
        else {
            DNSubscription *subscription = obj;
            if ([subscription shouldAutoAcknowledge] && !hasAcknowledged) {
                [self acknowledgeNotifications:notifications hasSubscribers:YES];
                hasAcknowledged = YES;
            }
            if ([subscription batchHandler]) {
                [subscription batchHandler](notifications);
            }
            else if ([subscription handler]) {
                //Notifications
                [notifications enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx2, BOOL *stop2) {
                    [subscription handler](obj2);
                }];
            }
        }
    }];
}

- (void)acknowledgeNotifications:(NSArray *)notifications hasSubscribers:(BOOL)hasSubscribers {
    NSMutableArray *acknowledged = [[NSMutableArray alloc] init];
    [notifications enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DNClientNotification *clientNotification = [[DNClientNotification alloc] initWithAcknowledgementNotification:obj];
        [[clientNotification acknowledgementDetails] dnSetObject:hasSubscribers ? DNDelivered : DNDeliveredNoSubscription forKey:DNResult];
        [acknowledged addObject:clientNotification];
    }];

    [[DNNetworkController sharedInstance] queueClientNotifications:acknowledged];
}

@end