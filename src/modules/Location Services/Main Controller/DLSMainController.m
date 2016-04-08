//
//  DLSMainController.m
//  Location Services Module
//
//  Created by Donky Networks on 22/10/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DLSMainController.h"
#import "DNDonkyCore.h"
#import "DNSystemHelpers.h"
#import "DNLoggingController.h"
#import "DNClientNotification.h"
#import "DNNetworkController.h"
#import "NSMutableDictionary+DNDictionary.h"
#import "DNConstants.h"
#import "NSDate+DNDateHelper.h"
#import "DNConfigurationController.h"

static NSString *const DLSLocationUpdateInterval = @"LocationUpdateIntervalSeconds";
static NSString *const DLSNetworkSendProfileID = @"sendToNetworkProfileId";
static NSString *const DLSNetworkProfileID = @"networkProfileId";
static NSString *const DLSUserID = @"userId";
static NSString *const DLSTargetUserKey = @"TargetUser";

@interface DLSMainController ()
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *lastValidLocation;
@property (nonatomic, strong) NSMutableArray *nextLocationUpdateBlocks;
@property (nonatomic, strong) NSTimer *reportLocationEverySecondsTimer;
@property (nonatomic, strong) NSTimer *locationUpdateTimer;

@property (nonatomic, strong) DNModuleDefinition *moduleDefinition;
@property (nonatomic, strong) DNSubscription *locationRequestSubscription;
@property (nonatomic, strong) DNSubscription *locationReceivedSubscription;

@property (nonatomic, copy) DNSubscriptionBatchHandler requestForLocationHandler;
@property (nonatomic, copy) DNSubscriptionBatchHandler userLocationReceived;
@property (nonatomic, copy) DNLocalEventHandler appOpenEvent;
@property(nonatomic, getter=isUsageOnly) BOOL usageOnly;
@end

@implementation DLSMainController

#pragma mark - OBJECT creation

+(DLSMainController *)sharedInstance
{
    static DLSMainController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DLSMainController alloc] initPrivate];
    });
    return sharedInstance;
}

-(instancetype)init {
    return [DLSMainController sharedInstance];
}

-(instancetype)initPrivate
{
    self = [super init];
    
    if (self) {
        
        [self setNextLocationUpdateBlocks:[[NSMutableArray alloc] init]];
        
        // report location every time interval
        [self setReportLocationTimeInterval:0];
        
        [self setAutoRespondToLocationRequests:NO];

        [self setModuleDefinition:[[DNModuleDefinition alloc] initWithName:NSStringFromClass([self class]) version:@"1.0.0.0"]];

        [self setLocationUpdateIntervalSeconds:[[DNConfigurationController objectFromConfiguration:DLSLocationUpdateInterval] integerValue] ? : 300];

        if (![self locationManager]) {
            [self setLocationManager:[[CLLocationManager alloc] init]];
        }

        [[self locationManager] setDelegate:self];

    }
    
    return  self;
}

+ (CLLocationManager *)locationServicesManager {
    return [[DLSMainController sharedInstance] locationManager];
}

#pragma mark - SETTERS

- (void)setReportLocationTimeInterval:(NSTimeInterval)reportLocationTimeInterval
{
    if (reportLocationTimeInterval != _reportLocationTimeInterval) {
        _reportLocationTimeInterval = reportLocationTimeInterval;
        
        [[self reportLocationEverySecondsTimer] invalidate];

        if (_reportLocationTimeInterval) {
            [self setReportLocationEverySecondsTimer:[NSTimer scheduledTimerWithTimeInterval:_reportLocationTimeInterval
                                                                  target:self
                                                                selector:@selector(timerReportLocation)
                                                                userInfo:nil
                                                                 repeats:YES]];
        }
    }
}

- (void)timerReportLocation {
    if ([self lastValidLocation]) {
        DNLocalEvent *locationManagerEvent = [[DNLocalEvent alloc] initWithEventType:kDLSLocationManagerDidFireLastKnownLocationTimer
                                                                           publisher:NSStringFromClass([self class])
                                                                           timeStamp:[NSDate date]
                                                                                data:@{@"locationManager" : [self locationManager], @"location" : [self lastValidLocation]}];
        [[DNDonkyCore sharedInstance] publishEvent:locationManagerEvent];
    }
}

- (void)setImplementorDefinedDistanceFilter:(CLLocationDistance)implementorDefinedDistanceFilter {
    if (implementorDefinedDistanceFilter != _implementorDefinedDistanceFilter) {
        _implementorDefinedDistanceFilter = implementorDefinedDistanceFilter;
        if (_implementorDefinedDistanceFilter) {
            [[self locationManager] setDistanceFilter:_implementorDefinedDistanceFilter];
        }
    }
}

#pragma mark - LOCATION Manager Start / Stop

- (void)startLocationTrackingServices {

    [self setAppOpenEvent:^(DNLocalEvent *event) {
        [DLSMainController sendLocationUpdateToUser:nil completionBlock:nil];
    }];

    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDNDonkyEventAppOpen handler:[self appOpenEvent]];

    [self setLocationRequestSubscription:[[DNSubscription alloc] initWithNotificationType:kDNDonkyNotificationLocationRequest batchHandler:[self requestForLocationHandler]]];
    [self setLocationReceivedSubscription:[[DNSubscription alloc] initWithNotificationType:kDNDonkyNotificationLocationReceived batchHandler:[self userLocationReceived]]];
    [[DNDonkyCore sharedInstance] subscribeToDonkyNotifications:[self moduleDefinition] subscriptions:@[[self locationRequestSubscription], [self locationReceivedSubscription]]];

    [self setLocationUpdateTimer:[NSTimer scheduledTimerWithTimeInterval:[self locationUpdateIntervalSeconds] target:self selector:@selector(timerDidFire:) userInfo:nil repeats:YES]];
}

- (void)stopLocationTrackingServices {
    [[DNDonkyCore sharedInstance] unSubscribeToLocalEvent:kDNDonkyEventAppOpen handler:[self appOpenEvent]];
    [[DNDonkyCore sharedInstance] unSubscribeToDonkyNotifications:[self moduleDefinition] subscriptions:@[[self locationRequestSubscription], [self locationReceivedSubscription]]];

    [[self locationUpdateTimer] invalidate];
    [self setLocationUpdateTimer:nil];
}

- (void)startWhenInUse {

    [self setUsageOnly:YES];
    
    //Start location manager:
    if ([DNSystemHelpers systemVersionAtLeast:8.0]) {
        //We check for the required keys:
        NSString *locationWhenInUseKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"];
        if (!locationWhenInUseKey) {
            DNErrorLog(@"Error - you must include the 'NSLocationWhenInUseUsageDescription' key in your applications 'Info.plist' in order to use Location Services on iOS 8+\nPlease add and try again...");
        }
        assert(locationWhenInUseKey);
    }

    [[self locationManager] startUpdatingLocation];
}

- (void)startAlwaysUsage {

    [self setUsageOnly:NO];

    [self setModuleDefinition:[[DNModuleDefinition alloc] initWithName:NSStringFromClass([self class]) version:@"1.0.0.0"]];
    [[DNDonkyCore sharedInstance] registerModule:self.moduleDefinition];

    if ([DNSystemHelpers systemVersionAtLeast:8.0]) {
        //We check for the required keys:
        NSString *locationAlwaysUsageKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"];
        if (!locationAlwaysUsageKey) {
            DNErrorLog(@"Error - you must include the 'NSLocationAlwaysUsageDescription' key in your applications 'Info.plist' in order to use Location Services on iOS 8+\nPlease add and try again...");
        }
        assert(locationAlwaysUsageKey);
    }

    [[self locationManager] startUpdatingLocation];
}

- (void)stopLocationUpdates {
    [[self locationManager] stopUpdatingLocation];
    [[self locationManager] setDelegate:nil];
}

- (void)startLocationUpdates {
    [self startAlwaysUsage];
}

#pragma mark - Location Manager States:

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {

    DNLocalEvent *locationManagerEvent = [[DNLocalEvent alloc] initWithEventType:kDLSLocationManagerDidChangeAuthorizationStatus publisher:NSStringFromClass([self class]) timeStamp:[NSDate date] data:@{@"locationManager" : manager, @"status" : @(status)}];
    [[DNDonkyCore sharedInstance] publishEvent:locationManagerEvent];

    switch (status) {
        case kCLAuthorizationStatusDenied:
             DNErrorLog(@"Location manager status: Authorization Denied. Cannot monitor for regions.");
            break;
        case kCLAuthorizationStatusRestricted:
            DNErrorLog(@"Location manager status: Restricted Authorization. Cannot monitor for regions.");
        case kCLAuthorizationStatusNotDetermined: {
            if ([DNSystemHelpers systemVersionAtLeast:8.0]) {
                if ([self isUsageOnly]) {
                    [[self locationManager] requestWhenInUseAuthorization];
                }
                else {
                    [[self locationManager] requestAlwaysAuthorization];
                }
            }
        }
        break;
        case kCLAuthorizationStatusAuthorizedAlways:
            [manager startUpdatingLocation];
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [manager startUpdatingLocation];
            break;
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    DNLocalEvent *locationManagerEvent = [[DNLocalEvent alloc] initWithEventType:kDLSLocationManagerDidFailWithError
                                                                       publisher:NSStringFromClass([self class])
                                                                       timeStamp:[NSDate date] data:@{@"locationManager" : manager, @"error" : error}];
    [[DNDonkyCore sharedInstance] publishEvent:locationManagerEvent];
}

#pragma mark - Location Updates:

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *locationUpdate = [locations lastObject];
    
    // update lastKnownLocation
    if (locationUpdate) {
        [self setLastValidLocation:locationUpdate];

        if ([[self nextLocationUpdateBlocks] count] && ([locationUpdate horizontalAccuracy] < 100 && [locationUpdate verticalAccuracy] < 100)){
            __block NSMutableArray *usedBlocks = [[NSMutableArray alloc] init];
            [[self nextLocationUpdateBlocks] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                DLSLocationUpdateBlock block = obj;
                if (block) {
                    block(manager, locationUpdate);
                }
                if (obj) {
                    [usedBlocks addObject:obj];
                }
            }];
            [[self nextLocationUpdateBlocks] removeObjectsInArray:usedBlocks];
        }
    }
    
    DNLocalEvent *locationManagerEvent = [[DNLocalEvent alloc] initWithEventType:kDLSLocationManagerDidUpdateLocations
                                                                       publisher:NSStringFromClass([self class])
                                                                       timeStamp:[NSDate date]
                                                                            data:@{@"locationManager" : manager, @"locations" : locations}];
    [[DNDonkyCore sharedInstance] publishEvent:locationManagerEvent];
}

- (void)requestSingleUserLocation:(DLSLocationUpdateBlock)completion {

    [[self nextLocationUpdateBlocks] addObject:completion];
    [self startWhenInUse];
  
}

#pragma mark - CLLocationManager DELEGATE

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    DNLocalEvent *locationManagerEvent = [[DNLocalEvent alloc] initWithEventType:kDLSLocationManagerDidUpdateHeading
                                                                       publisher:NSStringFromClass([self class])
                                                                       timeStamp:[NSDate date] data:@{@"locationManager" : manager, @"heading" : newHeading}];
    [[DNDonkyCore sharedInstance] publishEvent:locationManagerEvent];
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    DNLocalEvent *locationManagerEvent = [[DNLocalEvent alloc] initWithEventType:kDLSLocationManagerDidPauseLocationUpdates
                                                                       publisher:NSStringFromClass([self class])
                                                                       timeStamp:[NSDate date] data:@{@"locationManager" : manager}];
    [[DNDonkyCore sharedInstance] publishEvent:locationManagerEvent];
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    DNLocalEvent *locationManagerEvent = [[DNLocalEvent alloc] initWithEventType:kDLSLocationManagerDidResumeLocationUpdates
                                                                       publisher:NSStringFromClass([self class])
                                                                       timeStamp:[NSDate date] data:@{@"locationManager" : manager}];
    [[DNDonkyCore sharedInstance] publishEvent:locationManagerEvent];
}

#pragma mark - Region Monitoring:

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    DNLocalEvent *locationManagerEvent = [[DNLocalEvent alloc] initWithEventType:kDLSLocationManagerDidStartMonitoringForRegion
                                                                       publisher:NSStringFromClass([self class])
                                                                       timeStamp:[NSDate date] data:@{@"locationManager" : manager, @"region" : region}];
    [[DNDonkyCore sharedInstance] publishEvent:locationManagerEvent];

}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    DNLocalEvent *locationManagerEvent = [[DNLocalEvent alloc] initWithEventType:kDLSLocationManagerDidExitRegion
                                                                       publisher:NSStringFromClass([self class])
                                                                       timeStamp:[NSDate date] data:@{@"locationManager" : manager, @"region" : region}];
    [[DNDonkyCore sharedInstance] publishEvent:locationManagerEvent];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    DNLocalEvent *locationManagerEvent = [[DNLocalEvent alloc] initWithEventType:kDLSLocationManagerDidEnterRegion
                                                                       publisher:NSStringFromClass([self class])
                                                                       timeStamp:[NSDate date] data:@{@"locationManager" : manager, @"region" : region}];
    [[DNDonkyCore sharedInstance] publishEvent:locationManagerEvent];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    DNLocalEvent *locationManagerEvent = [[DNLocalEvent alloc] initWithEventType:kDLSLocationManagerDidDetermineStateForRegion
                                                                       publisher:NSStringFromClass([self class])
                                                                       timeStamp:[NSDate date] data:@{@"locationManager" : manager, @"region" : region, @"state" : @(state)}];
    [[DNDonkyCore sharedInstance] publishEvent:locationManagerEvent];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    
    DNLocalEvent *locationManagerEvent = [[DNLocalEvent alloc] initWithEventType:kDLSLocationManagerMonitoringDidFailForRegion
                                                                       publisher:NSStringFromClass([self class])
                                                                       timeStamp:[NSDate date] data:@{@"locationManager" : manager, @"region" : region, @"error" : error}];
    [[DNDonkyCore sharedInstance] publishEvent:locationManagerEvent];

}

#pragma mark - Sending Locations:

- (void)timerDidFire:(NSTimer *)timer {
    [DLSMainController sendLocationUpdateToUser:nil completionBlock:nil];
}

+ (void)requestUserLocation:(DLSTargetUser *)targetUser targetDeviceID:(NSString *)deviceId {

    NSMutableDictionary *user = [[NSMutableDictionary alloc] init];
    [user dnSetObject:[targetUser networkProfileID] forKey:DLSNetworkProfileID];
    [user dnSetObject:[targetUser userID] forKey:DLSUserID];

    NSMutableDictionary *userLocationRequest = [[NSMutableDictionary alloc] init];
    [userLocationRequest dnSetObject:user forKey:DLSTargetUserKey];
    [userLocationRequest dnSetObject:deviceId forKey:@"TargetDeviceId"];

    DNClientNotification *userRequest = [[DNClientNotification alloc] initWithType:kDLSLocationRequestNotification data:userLocationRequest acknowledgementData:nil];
    [[DNNetworkController sharedInstance] queueClientNotifications:@[userRequest] completion:^(id data) {
        [[DNNetworkController sharedInstance] synchronise];
    }];
}

+ (void)sendLocationUpdateToUser:(DLSTargetUser *)targetUser completionBlock:(DNCompletionBlock)completion {

    [[DLSMainController sharedInstance] requestSingleUserLocation:^(CLLocationManager *manager, CLLocation *userLocation) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSMutableDictionary *locationUpdate = [[NSMutableDictionary alloc] init];

            //If there is a target user:
            if (targetUser) {
                NSMutableDictionary *user = [[NSMutableDictionary alloc] init];
                [user dnSetObject:[targetUser networkProfileID] forKey:DLSNetworkProfileID];
                [user dnSetObject:[targetUser userID] forKey:DLSUserID];
                [locationUpdate dnSetObject:user forKey:@"notifyUser"];
            }

            NSMutableDictionary *location = [[NSMutableDictionary alloc] init];
            [location dnSetObject:@([userLocation coordinate].latitude) forKey:@"latitude"];
            [location dnSetObject:@([userLocation coordinate].longitude) forKey:@"longitude"];

            [locationUpdate dnSetObject:location forKey:@"location"];
            [locationUpdate dnSetObject:[[NSDate date] donkyDateForServer] forKey:@"timestamp"];

            DNClientNotification *userLocationNotification = [[DNClientNotification alloc] initWithType:kDLSLocationUpdateNotification data:locationUpdate acknowledgementData:nil];
            
            [[DNNetworkController sharedInstance] queueClientNotifications:@[userLocationNotification] completion:^(id data) {
                [[DNNetworkController sharedInstance] synchronise];
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    NSString *recipient = [targetUser userID] ? : [targetUser networkProfileID];
                    NSString *combinedLocation = [[NSString alloc] initWithFormat:@"%@ / %@", location[@"latitude"], location[@"longitude"]];
                    completion(@{@"Location" : combinedLocation, @"Sent to:" : recipient ? : @""});
                }
            });
        });
    }];
}

- (DNSubscriptionBatchHandler)requestForLocationHandler {
    __weak typeof(self) weakSelf = self;
    return ^(NSArray *batch) {
        [batch enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            DNServerNotification *notification = obj;
            if ([weakSelf shouldAutoRespondToLocationRequests]) {
                DLSTargetUser *targetUser = [[DLSTargetUser alloc] initWithUserID:nil networkProfileID:[notification data][DLSNetworkSendProfileID]];
                [DLSMainController sendLocationUpdateToUser:targetUser completionBlock:nil];
            }
            DNLocalEvent *locationRequest = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventLocationRequestReceived
                                                                          publisher:NSStringFromClass([weakSelf class])
                                                                          timeStamp:[NSDate date]
                                                                               data:@{DLSNetworkSendProfileID : [notification data][DLSNetworkSendProfileID]}];
            [[DNDonkyCore sharedInstance] publishEvent:locationRequest];
        }];
    };
}

- (DNSubscriptionBatchHandler)userLocationReceived {
    __weak typeof(self) weakSelf = self;
    return ^(NSArray *batch) {
        [batch enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            DNServerNotification *serverNotification = obj;
            DNLocalEvent *locationRequest = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventLocationReceived
                                                                          publisher:NSStringFromClass([weakSelf class])
                                                                          timeStamp:[NSDate date]
                                                                               data:@{@"data" : [serverNotification data]}];
            [[DNDonkyCore sharedInstance] publishEvent:locationRequest];
        }];
    };
}

@end