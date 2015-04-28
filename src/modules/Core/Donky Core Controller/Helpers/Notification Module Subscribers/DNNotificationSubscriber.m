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
#import "DNDataController.h"
#import "DNSubscription.h"
#import "DNModuleHelper.h"
#import "DNNetworkController.h"
#import "NSMutableDictionary+DNDictionary.h"

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
        if (![obj isKindOfClass:[DNSubscription class]])
            DNErrorLog(@"Something has gone wrong with. Expected DNSubscription (or subclass thereof) got: %@... Bailing out", NSStringFromClass([obj class]));
        else {
            DNSubscription *subscription = obj;
            [DNModuleHelper addModule:moduleDefinition toModuleList:[self donkyNotificationSubscribers] subscription:subscription];
        }
    }];
}

- (void)unSubscribeToDonkyNotifications:(DNModuleDefinition *)moduleDefinition subscriptions:(NSArray *)subscriptions {
    [subscriptions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[DNSubscription class]])
            DNErrorLog(@"Something has gone wrong with. Expected DNSubscription (or subclass thereof) got: %@... Bailing out", NSStringFromClass([obj class]));
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

- (void)notificationReceived:(DNServerNotification *)notification {
    NSArray *subscribers = nil;
    if ([[notification notificationType] isEqualToString:DNNotificationCustom]) {
        NSString *type = [notification data][DNNotificationCustomType];
        subscribers = [[self customNotificationSubscribers][type] allObjects];
    }
    else
        subscribers = [[self donkyNotificationSubscribers][[notification notificationType]] allObjects];

    [self processNotification:notification subscribers:subscribers];
}

- (void)processNotification:(DNServerNotification *)notification subscribers:(NSArray *)subscribers {
    [subscribers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[DNSubscription class]])
            DNErrorLog(@"Something has gone wrong with. Expected DNSubscription (or subclass thereof) got: %@... Bailing out", NSStringFromClass([obj class]));
        else {
            DNSubscription *subscription = obj;

            if ([subscription shouldAutoAcknowledge] && idx == 0)
                [self acknowledgeNotification:notification hasSubscribers:YES];

            if ([subscription handler])
                [subscription handler](notification);
        }
    }];

    if (![subscribers count])
        [self acknowledgeNotification:notification hasSubscribers:NO];
}

- (void)acknowledgeNotification:(DNServerNotification *)notification hasSubscribers:(BOOL)hasSubscribers {
    DNClientNotification *clientNotification = [[DNClientNotification alloc] initWithAcknowledgementNotification:notification];
    [clientNotification setNotificationType:DNAcknowledgement];
    [[clientNotification acknowledgementDetails] dnSetObject:hasSubscribers ? DNDelivered : DNDeliveredNoSubscription forKey:DNResult];
    [[DNNetworkController sharedInstance] queueClientNotifications:@[clientNotification]];
}



@end
