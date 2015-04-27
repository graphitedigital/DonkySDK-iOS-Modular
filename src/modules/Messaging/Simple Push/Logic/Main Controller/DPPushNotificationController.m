//
//  DPPushNotificationController.m
//  DonkyPushModule
//
//  Created by Chris Watson on 13/03/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import "DPPushNotificationController.h"
#import "DNDonkyCore.h"
#import "NSMutableDictionary+DNDictionary.h"
#import "DNConstants.h"
#import "DPConstants.h"
#import "DNClientNotification.h"
#import "DNNetworkController.h"
#import "DCMMainController.h"

static NSString *const DNPendingPushNotifications = @"PendingPushNotifications";
static NSString *const DNAnalyticsInfluencedAppOpens = @"DonkyAnalyticsInfluencedAppOpen";

static NSString *const DNInteractionResult = @"InteractionResult";

@interface DPPushNotificationController ()
@property(nonatomic, strong) DNModuleDefinition *moduleDefinition;
@property(nonatomic, copy) void (^pushLogicHandler)(id);
@property(nonatomic, copy) void (^eventHandler)(DNLocalEvent *);
@end

@implementation DPPushNotificationController

#pragma mark -
#pragma mark - Setup Singleton

+(DPPushNotificationController *)sharedInstance
{
    static DPPushNotificationController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DPPushNotificationController alloc] initPrivate];
    });
    return sharedInstance;
}

-(instancetype)init
{
    return [self initPrivate];
}

-(instancetype)initPrivate
{
    self = [super init];
    
    if (self) {
        
        [self setPendingPushNotifications:[[NSMutableArray alloc] init]];

        self.moduleDefinition = [[DNModuleDefinition alloc] initWithName:NSStringFromClass([self class]) version:@"1.0"];
    }
    
    return  self;
}

- (void)start {

    __weak DPPushNotificationController *weakSelf = self;

    self.pushLogicHandler = ^(id data) {
        [weakSelf pushNotificationReceived:data];
    };

    DNSubscription *subscription = [[DNSubscription alloc] initWithNotificationType:kDNDonkyNotificationSimplePush handler:self.pushLogicHandler];
    [subscription setAutoAcknowledge:NO];

    [[DNDonkyCore sharedInstance] subscribeToDonkyNotifications:self.moduleDefinition subscriptions:@[subscription]];

    self.eventHandler = ^(DNLocalEvent *event) {
        if ([event isKindOfClass:[DNLocalEvent class]]) {
            if ([[event data] isKindOfClass:[NSNumber class]])
                [weakSelf minusAppIconCount:[[event data] integerValue]];
        }
    };

    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDPDonkyEventChangeBadgeCount handler:self.eventHandler];

    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:DNInteractionResult handler:^(DNLocalEvent *event) {
        DNClientNotification *interactionResult = [[DNClientNotification alloc] initWithType:DNInteractionResult data:[event data] acknowledgementData:nil];
        [[DNNetworkController sharedInstance] queueClientNotifications:@[interactionResult]];
    }];
}

- (void)stop {

    DNSubscription *subscription = [[DNSubscription alloc] initWithNotificationType:kDNDonkyNotificationSimplePush handler:self.pushLogicHandler];

    [[DNDonkyCore sharedInstance] unSubscribeToDonkyNotifications:self.moduleDefinition subscriptions:@[subscription]];

    [[DNDonkyCore sharedInstance] unSubscribeToLocalEvent:kDPDonkyEventChangeBadgeCount handler:self.eventHandler];

}

#pragma mark -
#pragma mark - Core Logic

- (void)pushNotificationReceived:(DNServerNotification *)notification {

    //Clean out nulls:
    NSString *notificationID = [notification serverNotificationID];

    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        [[self pendingPushNotifications] addObject:notificationID];

        DNLocalEvent *pushOpenEvent = [[DNLocalEvent alloc] initWithEventType:DNAnalyticsInfluencedAppOpens
                                                                    publisher:NSStringFromClass([self class])
                                                                    timeStamp:[NSDate date]
                                                                         data:[self pendingPushNotifications]];
        [[DNDonkyCore sharedInstance] publishEvent:pushOpenEvent];
    }

    //Publish event:
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data dnSetObject:[self pendingPushNotifications] forKey:DNPendingPushNotifications];
    [data dnSetObject:notification forKey:kDNDonkyNotificationSimplePush];

    DNLocalEvent *pushEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyNotificationSimplePush
                                                            publisher:NSStringFromClass([self class])
                                                            timeStamp:[NSDate date]
                                                                 data:data];
    [[DNDonkyCore sharedInstance] publishEvent:pushEvent];

    //Mark as received:
    [DCMMainController markMessageAsReceived:notification];
}

- (void)minusAppIconCount:(NSInteger)count {
    NSInteger currentCount = [[UIApplication sharedApplication] applicationIconBadgeNumber];
    currentCount -= count;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:currentCount];
}

@end
