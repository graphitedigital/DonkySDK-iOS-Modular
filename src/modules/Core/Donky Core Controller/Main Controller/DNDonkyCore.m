//
//  DNDonkyCore.m
//  NAAS Core SDK Container
//
//  Created by Chris Watson on 18/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <MacTypes.h>
#import "DNDonkyCore.h"
#import "DNConstants.h"
#import "DNAccountController.h"
#import "DNErrorController.h"
#import "DNLoggingController.h"
#import "DNDonkyNetworkDetails.h"
#import "DNNotificationController.h"
#import "DNNetworkController.h"
#import "NSDate+DNDateHelper.h"
#import "DNOutboundModules.h"
#import "DNEventSubscriber.h"
#import "DNNotificationSubscriber.h"
#import "DNConfigurationController.h"
#import "DNModuleHelper.h"
#import "DNTag.h"

static NSString *const DNConfiguration = @"configuration";

@interface DNDonkyCore ()

@property(nonatomic, strong) NSTimer *authenticationTimer;
@property(nonatomic, strong) DNNotificationSubscriber *notificationSubscriber;
@property(nonatomic, strong) DNEventSubscriber *eventSubscriber;
@property(nonatomic, strong) DNOutboundModules *outboundModules;
@property(nonatomic, strong) DNRegisteredServices *registeredServices;
@property(nonatomic, strong) NSMutableArray *registeredModules;
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
        [self setRegisteredModules:[[NSMutableArray alloc] init]];

        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(applicationDidEnterForeground) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    
    return self;
}

- (void)applicationDidEnterForeground {
    DNLocalEvent *openAppEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventAppOpen publisher:NSStringFromClass([self class]) timeStamp:[NSDate date] data:nil];
    [self publishEvent:openAppEvent];
}

- (void)applicationDidEnterBackground {
    DNLocalEvent *openAppEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventAppClose publisher:NSStringFromClass([self class]) timeStamp:[NSDate date] data:nil];
    [self publishEvent:openAppEvent];
}

#pragma mark -
#pragma mark - Initialisation logic

- (void)initialiseWithAPIKey:(NSString *)apiKey {
    [self initialiseWithAPIKey:apiKey userDetails:[[DNAccountController registrationDetails] userDetails] deviceDetails:[[DNAccountController registrationDetails] deviceDetails] success:nil failure:nil];
}

- (void)initialiseWithAPIKey:(NSString *)apiKey userDetails:(DNUserDetails *)userDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    [self initialiseWithAPIKey:apiKey userDetails:userDetails deviceDetails:[[DNAccountController registrationDetails] deviceDetails] success:successBlock failure:failureBlock];
}

- (void)initialiseWithAPIKey:(NSString *)apiKey userDetails:(DNUserDetails *)userDetails deviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {

    if (!apiKey) {
        DNErrorLog(@"---- No API Key supplied - Bailing out of Donky Initialisation, please check input... ----");
        if (failureBlock)
            failureBlock(nil, [DNErrorController errorWithCode:DNCoreSDKErrorNoAPIKey]);
        return;
    }

    //Save the api key:
    [DNDonkyNetworkDetails saveAPIKey:apiKey];
    //Check if registered:ios moving app to background status
    [DNAccountController initialiseUserDetails:userDetails deviceDetails:deviceDetails success:^(NSURLSessionDataTask *task, id responseData) {
        [DNNotificationController registerForPushNotifications];
        [[DNNetworkController sharedInstance] startMinimumTimeForSynchroniseBuffer:0];
        
        [self addCoreSubscribers];
        
        [DNAccountController updateClientModules:[self allRegisteredModules]];
        
        DNInfoLog(@"DonkySDK is initilaised. All user data has been saved.");
        [[DNNetworkController sharedInstance] synchronise];
        if (successBlock)
            successBlock(task, responseData);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failureBlock)
            failureBlock(task, error);
    }];
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

- (void)notificationReceived:(DNServerNotification *)notification {
    [[self notificationSubscriber] notificationReceived:notification];
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
    DNModuleDefinition *moduleDefinition = [[DNModuleDefinition alloc] initWithName:NSStringFromClass([self class]) version:@"1.0.0.0"];
    DNSubscription *subscription = [[DNSubscription alloc] initWithNotificationType:kDNDonkyNotificationTransmitDebugLog handler:^(id data) {
        DNServerNotification *serverNotification = data;
        [DNLoggingController submitLogToDonkyNetwork:[serverNotification serverNotificationID] success:nil failure:nil];
    }];
    
    [subscription setAutoAcknowledge:YES];
    [self subscribeToDonkyNotifications:moduleDefinition subscriptions:@[subscription]];
}

@end
