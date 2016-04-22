//
//  DNDonkyCore.m
//  NAAS Core SDK Container
//
//  Created by Donky Networks on 18/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

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
@property (nonatomic, getter = isSettingBadgeCount) BOOL settingBadgeCount;
@property (nonatomic, strong) NSMutableArray *pendingBadgeCountUpdates;
@property (nonatomic, strong) DNRegisteredServices *registeredServices;
@property (nonatomic, readwrite, getter = isUsingAuth) BOOL usingAuth;
@property (nonatomic, strong) DNEventSubscriber *eventSubscriber;
@property (nonatomic, strong) DNOutboundModules *outboundModules;
@property (nonatomic, strong) NSMutableArray *registeredModules;
@end

@implementation DNDonkyCore

#pragma mark -
#pragma mark - Setup Singleton

+(DNDonkyCore *)sharedInstance {
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

#pragma mark -
#pragma mark - Initialisation logic

- (void)initialiseWithAPIKey:(NSString *)apiKey {
    [self initialiseWithAPIKey:apiKey
                   userDetails:[[DNAccountController registrationDetails] userDetails]
                 deviceDetails:[[DNAccountController registrationDetails] deviceDetails]
                       success:nil
                       failure:nil];
}

- (void)initialiseWithoutRegistrationAPIKey:(NSString *)apiKey {
    [self initialiseWithoutRegistrationAPIKey:apiKey succcess:nil failure:nil];
}

- (void)initialiseWithoutRegistrationAPIKey:(NSString *)apiKey succcess:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    __weak __typeof(self) weakSelf = self;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if (!apiKey || [apiKey length] == 0) {
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

        if ([DNAccountController isRegistered]) {
            [DNAccountController updateClientModules:[weakSelf allRegisteredModules]];
            [weakSelf addCoreSubscribers];

            [DNNotificationController registerForPushNotifications];
            [DNSignalRInterface openConnection];

            [self startObservers];

            DNLocalEvent *openAppEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventAppOpen
                                                                       publisher:NSStringFromClass([self class])
                                                                       timeStamp:[NSDate date]
                                                                            data:nil];
            [self publishEvent:openAppEvent];
        }

        DNUserDetails *currentUser = [[DNAccountController registrationDetails] userDetails];
        DNInfoLog(@"Donky SDK is initialised. All user data has been saved.\nCurrent userID = %@\nProfile ID = %@", [currentUser userID], [currentUser networkProfileID]);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (successBlock) {
                successBlock(nil, nil);
            }
        });
    });
}

- (void)initialiseWithAPIKey:(NSString *)apiKey succcess:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    [self initialiseWithAPIKey:apiKey
                   userDetails:[[DNAccountController registrationDetails] userDetails]
                 deviceDetails:[[DNAccountController registrationDetails] deviceDetails]
                       success:successBlock
                       failure:failureBlock];
}

- (void)initialiseWithAPIKey:(NSString *)apiKey userDetails:(DNUserDetails *)userDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    [self initialiseWithAPIKey:apiKey
                   userDetails:userDetails
                 deviceDetails:[[DNAccountController registrationDetails] deviceDetails]
                       success:successBlock
                       failure:failureBlock];
}

- (void)initialiseWithAPIKey:(NSString *)apiKey userDetails:(DNUserDetails *)userDetails deviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {

    __weak __typeof(self) weakSelf = self;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if (!apiKey || [apiKey length] == 0) {
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

            [DNAccountController updateClientModules:[weakSelf allRegisteredModules]];

            [weakSelf addCoreSubscribers];

            [DNSignalRInterface openConnection];
            [[DNNetworkController sharedInstance] synchronise];
            [DNNotificationController registerForPushNotifications];

            [self startObservers];

            DNLocalEvent *openAppEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventAppOpen
                                                                       publisher:NSStringFromClass([self class])
                                                                       timeStamp:[NSDate date]
                                                                            data:nil];
            [self publishEvent:openAppEvent];

            DNUserDetails *currentUser = [[DNAccountController registrationDetails] userDetails];
            DNInfoLog(@"Donky SDK is initialised. All user data has been saved.\nCurrent userID = %@\nProfile ID = %@", [currentUser userID], [currentUser networkProfileID]);
            dispatch_async(dispatch_get_main_queue(), ^{
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

- (void)authenticatedInitialiseWithAPIKey:(NSString *)apiKey {
    [self authenticatedInitialiseWithAPIKey:apiKey autoRegister:NO];
}

- (void)authenticatedInitialiseWithAPIKey:(NSString *)apiKey autoRegister:(BOOL)autoRegister {
    [self authenticatedInitialiseWithAPIKey:apiKey autoRegister:autoRegister success:nil failure:nil];
}

- (void)authenticatedInitialiseWithAPIKey:(NSString *)apiKey autoRegister:(BOOL)autoRegister success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {

    __weak __typeof(self) weakSelf = self;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if (!apiKey || [apiKey length] == 0) {
            DNErrorLog(@"---- No API Key supplied - Bailing out of Donky Initialisation, please check input... ----");
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failureBlock) {
                    failureBlock(nil, [DNErrorController errorWithCode:DNCoreSDKErrorNoAPIKey]);
                }
            });
            return;
        }
        
        [self setUsingAuth:YES];

        //Save the api key:
        [DNDonkyNetworkDetails saveAPIKey:apiKey];

        if ([DNAccountController isRegistered]) {

            [DNAccountController updateClientModules:[weakSelf allRegisteredModules]];
            [weakSelf addCoreSubscribers];

            [DNNotificationController registerForPushNotifications];
            [DNSignalRInterface openConnection];

            [self startObservers];

            DNLocalEvent *openAppEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventAppOpen
                                                                       publisher:NSStringFromClass([self class])
                                                                       timeStamp:[NSDate date]
                                                                            data:nil];
            [self publishEvent:openAppEvent];
        }
        else if (autoRegister) {
            
             DNAuthenticationCompletion block = ^(NSString *token, DNAuthResponse *authResponse) {
                 [DNAccountController authenticatedRegistrationForUser:nil
                                                                device:nil
                                                  authenticationDetail:authResponse
                                                                 token:token
                                                               success:^(NSURLSessionDataTask *task, id responseData) {
                     if (successBlock) {
                         successBlock(task, responseData);
                     }
                 } failure:^(NSURLSessionDataTask *task, NSError *error) {
                     if (failureBlock) {
                         failureBlock(task, error   );
                     }
                 }];
             };

            DNAuthenticationObject *authenticationObject = [[DNAuthenticationObject alloc] initWithUserID:[[[DNAccountController registrationDetails] userDetails] userID]
                                                                                                    nonce:nil];
            [DNAccountController startAuthenticationWithCompletion:^(DNAuthResponse *authDetails, DNAuthenticationObject *expectedDetails, NSError *error) {
                if ([self authenticationHandler]) {
                    [self authenticationHandler](block, authDetails, authenticationObject);
                }
            }];
        }

        DNUserDetails *currentUser = [[DNAccountController registrationDetails] userDetails];
        DNInfoLog(@"Donky SDK is initialised. All user data has been saved.\nCurrent userID = %@\nProfile ID = %@", [currentUser userID], [currentUser networkProfileID]);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (successBlock) {
                successBlock(nil, nil);
            }
        });
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
    if (![self isModuleRegistered:[moduleDefinition name] moduleVersion:[moduleDefinition version]]) {
        [[self registeredModules] addObject:moduleDefinition];
        [DNAccountController updateClientModules:@[moduleDefinition]];
    }
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
    
    DNModuleDefinition *moduleDefinition = [[DNModuleDefinition alloc] initWithName:NSStringFromClass([self class])
                                                                            version:kDNDonkyCoreVersion];

    DNSubscription *transmitDebugLog = [[DNSubscription alloc] initWithNotificationType:kDNDonkyNotificationTransmitDebugLog
                                                                           batchHandler:^(NSArray *batch) {
        [batch enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            DNServerNotification *serverNotification = obj;
            [DNLoggingController submitLogToDonkyNetwork:[serverNotification serverNotificationID] success:nil failure:nil];
        }];
    }];

    DNSubscription *newDeviceMessage = [[DNSubscription alloc] initWithNotificationType:kDNDonkyNotificationNewDeviceMessage
                                                                           batchHandler:^(NSArray *batch) {
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

    DNSubscription *userUpdatedSubscription = [[DNSubscription alloc] initWithNotificationType:@"UserUpdated"
                                                                                  batchHandler:^(NSArray *batch) {
        [batch enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            DNServerNotification *userUpdated = obj;
            DNUserDetails *newUserDetails = [[DNUserDetails alloc] initWithUserID:[userUpdated data][@"newExternalUserId"] ? : [userUpdated data][@"externalUserId"]
                                                                      displayName:[userUpdated data][@"displayName"]
                                                                     emailAddress:[userUpdated data][@"emailAddress"]
                                                                     mobileNumber:[userUpdated data][@"phoneNumber"]
                                                                      countryCode:[userUpdated data][@"countryIsoCode"]
                                                                        firstName:[userUpdated data][@"firstName"]
                                                                         lastName:[userUpdated data][@"lastName"]
                                                                         avatarID:[userUpdated data][@"avatarId"]
                                                                     selectedTags:[userUpdated data][@"selectedTags"]
                                                             additionalProperties:[userUpdated data][@"additionalProperties"]
                                                                        anonymous:[[userUpdated data][@"isAnonymous"] boolValue]];
            [DNAccountController saveUserDetails:newUserDetails];
        }];
    }];

    [self subscribeToDonkyNotifications:moduleDefinition subscriptions:@[transmitDebugLog, newDeviceMessage, userUpdatedSubscription]];

    if ([self useDonkyBadgeCounts]) {

        [self subscribeToLocalEvent:kDNDonkySetBadgeCount handler:^(DNLocalEvent *event) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSInteger badgeCount = [[event data] integerValue];

                if (badgeCount < 0) {
                    badgeCount = 0;
                }

                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeCount];

                DNInfoLog(@"Setting local and network badge count to: %ld", (long) badgeCount);

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

- (void)startObservers {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        DNLocalEvent *appCloseEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventAppClose
                                                                    publisher:NSStringFromClass([self class])
                                                                    timeStamp:[NSDate date]
                                                                         data:nil];
        [self publishEvent:appCloseEvent];
        
        if ([DNAccountController isRegistered]) {
            [DNSignalRInterface closeConnection];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            DNLocalEvent *openAppEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventAppOpen
                                                                       publisher:NSStringFromClass([self class])
                                                                       timeStamp:[NSDate date]
                                                                            data:nil];
            [self publishEvent:openAppEvent];
            
            if ([DNAccountController isRegistered]) {
                [DNSignalRInterface openConnection];
                [[DNNetworkController sharedInstance] synchroniseSuccess:^(NSURLSessionDataTask *task, id responseData) {
                   [DNNotificationController resetApplicationBadgeCount];
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    
                }];
            }
        });
    }];
}

@end