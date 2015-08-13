//
//  DNNotificationSubscriber.m
//  Donky Network SDK Container
//
//  Created by Chris Watson on 06/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNNotificationSubscriber.h"
#import "DNLoggingController.h"
#import "DNAccountController.h"
#import "DNSubscription.h"
#import "DNModuleHelper.h"
#import "DNNetworkController.h"
#import "NSMutableDictionary+DNDictionary.h"
#import "DNClientNotification.h"
#import "DNDataController.h"

static NSString *const DNNotificationCustom = @"Custom";
static NSString *const DNNotificationCustomType = @"customType";
static NSString *const DNAcknowledgement = @"Acknowledgement";
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
        if (![obj isKindOfClass:[DNSubscription class]])
            DNErrorLog(@"Something has gone wrong with. Expected DNSubscription (or subclass thereof) got: %@... Bailing out", NSStringFromClass([obj class]));
        else {
            DNSubscription *subscription = obj;
            [subscription setAutoAcknowledge:YES];
            [DNModuleHelper addModule:moduleDefinition toModuleList:[self customNotificationSubscribers] subscription:subscription];
        }
    }];
}

- (void)unSubscribeToNotifications:(DNModuleDefinition *)moduleDefinition subscriptions:(NSArray *)subscriptions {
    [subscriptions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[DNSubscription class]])
            DNErrorLog(@"Something has gone wrong with. Expected DNSubscription (or subclass thereof) got: %@... Bailing out", NSStringFromClass([obj class]));
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
            subscribers = [[self customNotificationSubscribers][key] allObjects];
        }
        else {
            subscribers = [[self donkyNotificationSubscribers][key] allObjects];
        }
        if (subscribers) {
            [self processNotifications:obj subscribers:subscribers];
        }
        else {
            DNInfoLog(@"No subscribers for: %@", key);
            [self acknowledgeNotifications:obj hasSubscribers:NO];
        }
    }];
}

- (void)processNotifications:(NSArray *)notifications subscribers:(NSArray *)subscribers {

    __block BOOL hasAcknowledged = NO;
    [subscribers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[DNSubscription class]])
            DNErrorLog(@"Something has gone wrong with. Expected DNSubscription (or subclass thereof) got: %@... Bailing out", NSStringFromClass([obj class]));
        else {
            DNSubscription *subscription = obj;
            if ([subscription shouldAutoAcknowledge] && !hasAcknowledged) {
                [self acknowledgeNotifications:notifications hasSubscribers:YES];
                hasAcknowledged = YES;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([subscription batchHandler]) {
                    [subscription batchHandler](notifications);
                }
                else if ([subscription handler]) {
                    //Notifications
                    [notifications enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx2, BOOL *stop2) {
                        [subscription handler](obj2);
                    }];
                }
            });
        }
    }];

    if (![subscribers count]) {
        [self acknowledgeNotifications:notifications hasSubscribers:NO];
    }

    [[DNDataController sharedInstance] saveAllData];
}

- (void)acknowledgeNotifications:(NSArray *)notifications hasSubscribers:(BOOL)hasSubscribers {
    [notifications enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DNClientNotification *clientNotification = [[DNClientNotification alloc] initWithAcknowledgementNotification:obj];
        [clientNotification setNotificationType:DNAcknowledgement];
        [[clientNotification acknowledgementDetails] dnSetObject:hasSubscribers ? DNDelivered : DNDeliveredNoSubscription forKey:DNResult];
        [[DNNetworkController sharedInstance] queueClientNotifications:@[clientNotification]];
    }];
}

@end
