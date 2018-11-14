//
//  DPPushNotificationController.m
//  DonkyPushModule
//
//  Created by Donky Networks on 13/03/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DPPushNotificationController.h"
#import <Donky_Core_SDK/DNDonkyCore.h>
#import <Donky_Core_SDK/NSMutableDictionary+DNDictionary.h>
#import <Donky_Core_SDK/DNConstants.h>
#import <Donky_Core_SDK/DNClientNotification.h>
#import <Donky_Core_SDK/DNNetworkController.h>
#import <Donky_CommonMessaging_Logic/DCMMainController.h>
#import <Donky_Core_SDK/DCAConstants.h>
#import <Donky_Core_SDK/DNNotificationController.h>

static NSString *const DNInteractionResult = @"InteractionResult";

@interface DPPushNotificationController ()
@property (nonatomic, strong) DNModuleDefinition *moduleDefinition;
@property (nonatomic, copy) DNSubscriptionBatchHandler pushLogicHandler;
@property (nonatomic, copy) DNLocalEventHandler interactionEvent;
@property (nonatomic, strong) NSMutableArray *seenNotifications;
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

-(instancetype)init {
    return [self initPrivate];
}

-(instancetype)initPrivate {
    self = [super init];
    
    if (self) {
        
        [self setModuleDefinition:[[DNModuleDefinition alloc] initWithName:NSStringFromClass([self class]) version:@"1.2.0.2"]];
        
        [self setSeenNotifications:[[NSMutableArray alloc] init]];
    }
    
    return  self;
}

- (void) dealloc {
    [self stop];
}

- (void)start {

    __weak __typeof(self) weakSelf = self;

    [self setPushLogicHandler:^(NSArray *batch) {
        NSArray *batchNotifications = batch;
        [batchNotifications enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            DNServerNotification *original = obj;
            __block BOOL seen = NO;
            [[weakSelf seenNotifications] enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx2, BOOL * stop2) {
                DNServerNotification *server = obj2;
                if ([[original serverNotificationID] isEqualToString:[server serverNotificationID]]) {
                    seen = YES;
                    *stop2 = YES;
                }
            }];
            
            if ([obj isKindOfClass:[DNServerNotification class]] && !seen) {
                [[weakSelf seenNotifications] addObject:obj];
                [weakSelf pushNotificationReceived:obj];
            }
        }];

        [DNNotificationController resetApplicationBadgeCount];
        [DCMMainController markAllMessagesAsReceived:batchNotifications];
    }];
        
    //Simple Push:
    [self setSimplePushMessage:[[DNSubscription alloc] initWithNotificationType:kDNDonkyNotificationSimplePush
                                                                   batchHandler:[self pushLogicHandler]]];

    [[DNDonkyCore sharedInstance] subscribeToDonkyNotifications:[self moduleDefinition]
                                                  subscriptions:@[[self simplePushMessage]]];

    [self setInteractionEvent:^(DNLocalEvent *event) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            DNClientNotification *interactionResult = [[DNClientNotification alloc] initWithType:DNInteractionResult
                                                                                            data:[event data]
                                                                             acknowledgementData:nil];
            [[DNNetworkController sharedInstance] queueClientNotifications:@[interactionResult]];
        });
    }];

    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:DNInteractionResult handler:[self interactionEvent]];
 
}

- (void)stop {
    [[DNDonkyCore sharedInstance] unSubscribeToDonkyNotifications:[self moduleDefinition]
                                                    subscriptions:@[[self simplePushMessage]]];
    [[DNDonkyCore sharedInstance] unSubscribeToLocalEvent:DNInteractionResult
                                                  handler:[self interactionEvent]];
}

#pragma mark -
#pragma mark - Core Logic

- (void)pushNotificationReceived:(DNServerNotification *)notification {

    NSString *pushNotificationId = [NSString stringWithFormat:@"com.donky.push.%@", [notification serverNotificationID]];
    NSString *notificationID = [[NSUserDefaults standardUserDefaults] objectForKey:pushNotificationId];
    
    if (notificationID) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:pushNotificationId];
        [[NSUserDefaults standardUserDefaults] synchronize];
        DNLocalEvent *pushOpenEvent = [[DNLocalEvent alloc] initWithEventType:kDAEventInfluencedAppOpen
                                                                    publisher:NSStringFromClass([self class])
                                                                    timeStamp:[NSDate date]
                                                                         data:[notification serverNotificationID]];
        [[DNDonkyCore sharedInstance] publishEvent:pushOpenEvent];
    }

    //Publish event:
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data dnSetObject:notification forKey:kDNDonkyNotificationSimplePush];

    DNLocalEvent *pushEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyNotificationSimplePush
                                                            publisher:NSStringFromClass([self class])
                                                            timeStamp:[NSDate date]
                                                                 data:data];
    [[DNDonkyCore sharedInstance] publishEvent:pushEvent];
}

@end
