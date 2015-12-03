//
//  DNDonkyCore.m
//  NAAS Core SDK Container
//
//  Created by Donky Networks on 18/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNDonkyCore.h"
#import "DNConstants.h"
#import "DNAccountController.h"
#import "DNErrorController.h"
#import "DNLoggingController.h"
#import "DNDonkyNetworkDetails.h"
#import "DNNotificationController.h"
#import "DNNetworkController.h"
#import "DNOutboundModules.h"
#import "DNEventSubscriber.h"
#import "DNNotificationSubscriber.h"
#import "DNModuleHelper.h"
#import "DNDonkyCoreFunctionalHelper.h"
#import "DNClientNotification.h"
#import "DNSignalRInterface.h"
#import "DNQueueManager.h"

@interface DNDonkyCore ()
@property (nonatomic, strong) DNNotificationSubscriber *notificationSubscriber;
@property (nonatomic, getter=isSettingBadgeCount) BOOL settingBadgeCount;
@property (nonatomic, strong) NSMutableArray *pendingBadgeCountUpdates;
@property (nonatomic, strong) DNRegisteredServices *registeredServices;
@property (nonatomic, strong) DNEventSubscriber *eventSubscriber;
@property (nonatomic, strong) DNOutboundModules *outboundModules;
@property (nonatomic, strong) NSMutableArray *registeredModules;
@end

@implementation DNDonkyCore

#pragma mark -
#pragma mark - Setup Singleton

+(DNDonkyCore *)sharedInstance
{
    static dispatch_once_t pred;
    static DNDonkyCore *sharedInstance = nil;

    dispatch_once(&pred, ^{
        sharedInstance = [[DNDonkyCore alloc] initPrivate];
    });
    return sharedInstance;
}

-(instancetype)init {
    return [DNDonkyCore sharedInstance];
}

-(instancetype)initPrivate
{
    self  = [super init];
    if (self) {
        [self setNotificationSubscriber:[[DNNotificationSubscriber alloc] init]];
        [self setEventSubscriber:[[DNEventSubscriber alloc] init]];
        [self setOutboundModules:[[DNOutboundModules alloc] init]];
        [self setRegisteredServices:[[DNRegisteredServices alloc] init]];

        [self setPendingBadgeCountUpdates:[[NSMutableArray alloc] init]];
        [self setRegisteredModules:[[NSMutableArray alloc] init]];

        [self setDonkyBadgeCounts:YES];

        [self setDisplayNewDeviceAlert:NO];

        DNClientDetails *clientDetails = [[DNClientDetails alloc] init];

        [[clientDetails moduleVersions] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            DNModuleDefinition *moduleDefinition = [[DNModuleDefinition alloc] initWithName:key version:obj];
            [[self registeredModules] addObject:moduleDefinition];
        }];
    }
    
    return self;
}

- (void)applicationWillEnterForegroundNotification {
    DNLocalEvent *openAppEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventAppWillEnterForegroundNotification publisher:NSStringFromClass([self class]) timeStamp:[NSDate date] data:nil];
    [self publishEvent:openAppEvent];

    //Open signalR connection
    if ([DNAccountController isRegistered]) {
        [DNSignalRInterface openConnection];
    }
}

- (void)applicationDidEnterForeground {
    DNLocalEvent *openAppEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventAppOpen publisher:NSStringFromClass([self class]) timeStamp:[NSDate date] data:nil];
    [self publishEvent:openAppEvent];
    if ([DNAccountController isRegistered]) {
        [[DNNetworkController sharedInstance] synchroniseSuccess:^(NSURLSessionDataTask *task, id responseData) {
            [DNNotificationController resetApplicationBadgeCount];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
    }
}

- (void)applicationDidEnterBackground {
    DNLocalEvent *openAppEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventAppClose publisher:NSStringFromClass([self class]) timeStamp:[NSDate date] data:nil];
    [self publishEvent:openAppEvent];

    if ([DNAccountController isRegistered]) {
        [DNSignalRInterface closeConnection];
    }
}

#pragma mark -
#pragma mark - Initialisation logic

+ (void)initialiseWithAPIKey:(NSString *)apiKey userDetails:(DNUserDetails *)userDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    [[DNDonkyCore sharedInstance] initialiseWithAPIKey:apiKey userDetails:userDetails success:successBlock failure:failureBlock];
}

+ (void)initialiseWithAPIKey:(NSString *)apiKey userDetails:(DNUserDetails *)userDetails deviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    [[DNDonkyCore sharedInstance] initialiseWithAPIKey:apiKey userDetails:userDetails deviceDetails:deviceDetails success:successBlock failure:failureBlock];
}

+ (void)initialiseWithAPIKey:(NSString *)apiKey succcess:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    [[DNDonkyCore sharedInstance] initialiseWithAPIKey:apiKey succcess:successBlock failure:failureBlock];
}


- (void)initialiseWithAPIKey:(NSString *)apiKey {
    [self initialiseWithAPIKey:apiKey userDetails:[[DNAccountController registrationDetails] userDetails] deviceDetails:[[DNAccountController registrationDetails] deviceDetails] success:nil failure:nil];
}

+ (void)initialiseWithAPIKey:(NSString *)apiKey {
    [[DNDonkyCore sharedInstance] initialiseWithAPIKey:apiKey];
}

- (void)initialiseWithAPIKey:(NSString *)apiKey succcess:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    [self initialiseWithAPIKey:apiKey userDetails:[[DNAccountController registrationDetails] userDetails] deviceDetails:[[DNAccountController registrationDetails] deviceDetails]  success:successBlock failure:failureBlock];
}

- (void)initialiseWithAPIKey:(NSString *)apiKey userDetails:(DNUserDetails *)userDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    [self initialiseWithAPIKey:apiKey userDetails:userDetails deviceDetails:[[DNAccountController registrationDetails] deviceDetails] success:successBlock failure:failureBlock];
}

- (void)initialiseWithAPIKey:(NSString *)apiKey userDetails:(DNUserDetails *)userDetails deviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {

    __weak __typeof(self) weakSelf = self;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if (!apiKey || apiKey.length == 0) {
            DNErrorLog(@"---- No API Key supplied - Bailing out of Donky Initialisation, please check input... ----");
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failureBlock) {
                    failureBlock(nil, [DNErrorController errorWithCode:DNCoreSDKErrorNoAPIKey]);
                }
            });
            return;
        }

        //Save the api key:
        [DNDonkyNetworkDetails saveAPIKey:apiKey];

        //Check if registered:ios moving app to background status
        [DNAccountController initialiseUserDetails:userDetails deviceDetails:deviceDetails success:^(NSURLSessionDataTask *task, id responseData) {

            [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(applicationDidEnterForeground) name:UIApplicationDidBecomeActiveNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(applicationWillEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];

            [DNAccountController updateClientModules:[weakSelf allRegisteredModules]];

            [weakSelf addCoreSubscribers];

            [DNSignalRInterface openConnection];
            [[DNNetworkController sharedInstance] synchronise];
            [DNNotificationController registerForPushNotifications];

            dispatch_async(dispatch_get_main_queue(), ^{
                DNInfoLog(@"DonkySDK is initialised. All user data has been saved.");
                if (successBlock) {
                    successBlock(task, responseData);
                }
            });
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failureBlock) {
                    failureBlock(task, error);
                }
            });
        }];
    });
}

#pragma mark -
#pragma mark - Local Events

- (void)subscribeToLocalEvent:(NSString *)eventType handler:(DNLocalEventHandler)eventHandler {
    [[self eventSubscriber] subscribeToLocalEvent:eventType handler:eventHandler];
}

- (void)unSubscribeToLocalEvent:(NSString *)eventType handler:(DNLocalEventHandler)handler {
    [[self eventSubscriber] unSubscribeToLocalEvent:eventType handler:handler];
}

- (void)publishEvent:(DNLocalEvent *)event {
    [[self eventSubscriber] publishEvent:event];
}

#pragma mark -
#pragma mark - Notifications

- (void)subscribeToDonkyNotifications:(DNModuleDefinition *)moduleDefinition subscriptions:(NSArray *)subscriptions {
    [[self notificationSubscriber] subscribeToDonkyNotifications:moduleDefinition subscriptions:subscriptions];
    [self registerModule:moduleDefinition];
}

- (void)unSubscribeToDonkyNotifications:(DNModuleDefinition *)moduleDefinition subscriptions:(NSArray *)subscriptions {
    [[self notificationSubscriber] unSubscribeToDonkyNotifications:moduleDefinition subscriptions:subscriptions];
}

- (void)subscribeToContentNotifications:(DNModuleDefinition *)moduleDefinition subscriptions:(NSArray *)subscriptions {
    [[self notificationSubscriber] subscribeToNotifications:moduleDefinition subscriptions:subscriptions];
    [self registerModule:moduleDefinition];
}

- (void)unSubscribeToContentNotifications:(DNModuleDefinition *)moduleDefinition subsciptions:(NSArray *)subscriptions {
    [[self notificationSubscriber] unSubscribeToNotifications:moduleDefinition subscriptions:subscriptions];
}

- (void)notificationsReceived:(NSDictionary *)dictionary {
    [[self notificationSubscriber] notificationsReceived:dictionary];
}

#pragma mark -
#pragma mark - Outbound Notifications:

- (void)subscribeToOutboundNotifications:(DNModuleDefinition *)moduleDefinition subscriptions:(NSArray *)subscriptions {
    [[self outboundModules] subscribeToOutboundNotifications:moduleDefinition subscriptions:subscriptions];
}

- (void)unSubscribeToOutboundNotifications:(DNModuleDefinition *)moduleDefinition subscriptions:(NSArray *)subscriptions {
    [[self outboundModules] unSubscribeToOutboundNotifications:moduleDefinition subscriptions:subscriptions];
}

- (void)publishOutboundNotification:(NSString *)type data:(id)data {
    [[self outboundModules] publishOutboundNotification:type data:data];
}

#pragma mark -
#pragma mark - Registered Services

- (void)registerService:(NSString *)type instance:(id)instance {
    [[self registeredServices] registerService:type instance:instance];
}

- (void)unRegisterService:(NSString *)type {
    [[self registeredServices] unRegisterService:type];
}

- (id)serviceForType:(NSString *) type {
    return [[self registeredServices] serviceForType:type];
}

#pragma mark -
#pragma mark - Modules

- (void)registerModule:(DNModuleDefinition *)moduleDefinition {
    [[self registeredModules] addObject:moduleDefinition];
    [DNAccountController updateClientModules:@[moduleDefinition]];
}

- (BOOL)isModuleRegistered:(NSString *)moduleName moduleVersion:(NSString *)moduleVersion {
    return [DNModuleHelper isModuleRegistered:[self registeredModules] moduleName:moduleName moduleVersion:moduleVersion];
}

- (NSArray *)allRegisteredModules {
    return [self registeredModules];
}

#pragma mark -
#pragma mark - Donky Core Notifications

- (void)addCoreSubscribers {
    
    __weak DNDonkyCore *weakSelf = self;
    
    DNModuleDefinition *moduleDefinition = [[DNModuleDefinition alloc] initWithName:NSStringFromClass([self class]) version:kDNDonkyCoreVersion];

    DNSubscription *transmitDebugLog = [[DNSubscription alloc] initWithNotificationType:kDNDonkyNotificationTransmitDebugLog batchHandler:^(NSArray *batch) {
        [batch enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            DNServerNotification *serverNotification = obj;
            [DNLoggingController submitLogToDonkyNetwork:[serverNotification serverNotificationID] success:nil failure:nil];
        }];
    }];

    DNSubscription *newDeviceMessage = [[DNSubscription alloc] initWithNotificationType:kDNDonkyNotificationNewDeviceMessage batchHandler:^(NSArray *batch) {
        [batch enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            DNServerNotification *serverNotification = obj;
            if ([weakSelf shouldDisplayNewDeviceAlert]) {
                [DNDonkyCoreFunctionalHelper handleNewDeviceMessage:serverNotification];
            }
            //Create a new event:
            DNLocalEvent *newDeviceEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyNotificationNewDeviceMessage
                                                                             publisher:NSStringFromClass([weakSelf class])
                                                                             timeStamp:[NSDate date]
                                                                                  data:[serverNotification data]];
            [weakSelf publishEvent:newDeviceEvent];
        }];
    }];

    [self subscribeToDonkyNotifications:moduleDefinition subscriptions:@[transmitDebugLog, newDeviceMessage]];

    if ([self useDonkyBadgeCounts]) {

        [self subscribeToLocalEvent:kDNDonkySetBadgeCount handler:^(DNLocalEvent *event) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSInteger badgeCount = [[event data] integerValue];

                if (badgeCount < 0) {
                    badgeCount = 0;
                }

                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeCount];

                DNInfoLog(@"Setting local and network badge count to: %ld", (long)badgeCount);

                //We need to updatresetApplicationBadgeCounte the server side badge count:
                DNClientNotification *badgeCountNotification = [[DNClientNotification alloc] initWithType:@"SetBadgeCount" data:@{@"BadgeCount" : @(badgeCount)} acknowledgementData:nil];

                if ([weakSelf isSettingBadgeCount]) {
                    @synchronized ([weakSelf pendingBadgeCountUpdates]) {
                        [[weakSelf pendingBadgeCountUpdates] addObject:badgeCountNotification];
                        return;
                    }
                }

                [weakSelf setSettingBadgeCount:YES];
                [[DNNetworkController sharedInstance] queueClientNotifications:@[badgeCountNotification]];
                [weakSelf syncBadgeCount];
            });
        }];

        [DNNotificationController resetApplicationBadgeCount];
    }
    
    DNLocalEvent *openAppEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventAppOpen publisher:NSStringFromClass([self class]) timeStamp:[NSDate date] data:nil];
    [self publishEvent:openAppEvent];
}

- (void)syncBadgeCount {
    [[DNNetworkController sharedInstance] synchroniseSuccess:^(NSURLSessionDataTask *task, id responseData) {
        @synchronized ([self pendingBadgeCountUpdates]) {
            if ([[self pendingBadgeCountUpdates] count]) {
                [[DNNetworkController sharedInstance] queueClientNotifications:@[[[self pendingBadgeCountUpdates] firstObject]]];
                [[self pendingBadgeCountUpdates] removeObjectAtIndex:0];
                [self syncBadgeCount];
            }
            else {
                [self setSettingBadgeCount:NO];
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self setSettingBadgeCount:NO];
    }];
}

@end