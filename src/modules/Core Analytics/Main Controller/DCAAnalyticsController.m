//
//  DCAAnalyticsController.m
//  DonkyCoreAnalytics
//
//  Created by Donky Networks on 01/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DCAAnalyticsController.h"
#import "DNConstants.h"
#import "DNDonkyCore.h"
#import "DNClientNotification.h"
#import "NSMutableDictionary+DNDictionary.h"
#import "NSDate+DNDateHelper.h"
#import "DNNetworkController.h"
#import "DNLoggingController.h"
#import "DCAConstants.h"

static NSString *const DALaunchTimeUTC = @"launchTimeUtc";
static NSString *const DASessionTrigger = @"sessionTrigger";
static NSString *const DAOperatingSystem = @"operatingSystem";
static NSString *const DAAppLaunch = @"appLaunch";
static NSString *const DAAppLaunchDefaults = @"DonkyAppLaunch";
static NSString *const DAStartTimeUTC = @"startTimeUtc";
static NSString *const DAEndTimeUTC = @"endTimeUtc";
static NSString *const DAAppSession = @"appSession";
static NSString *const DCANoneSession = @"None";
static NSString *const DCANotificationSession = @"Notification";

@interface DCAAnalyticsController ()
@property (nonatomic, strong) dispatch_queue_t donkyAnalyticsProcessingQueue;
@property (nonatomic, copy) void (^appOpenEvent)(DNLocalEvent *);
@property (nonatomic, copy) void (^appCloseEvent)(DNLocalEvent *);
@property (nonatomic, copy) void (^appInfluenceEvent)(DNLocalEvent *);
@end

@implementation DCAAnalyticsController

+(DCAAnalyticsController *)sharedInstance {
    static DCAAnalyticsController *sharedInstance = nil;
    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        sharedInstance = [[DCAAnalyticsController alloc] initPrivate];

        sharedInstance->_donkyAnalyticsProcessingQueue = dispatch_queue_create("com.donkySDK.AnalyticsProcessing", DISPATCH_QUEUE_CONCURRENT);
    });
    return sharedInstance;
}

-(instancetype)initPrivate {
    self = [super init];
    
    if (self) {

    }

    return self;
}

- (instancetype) init {
    return [self initPrivate];
}

- (void)start {
    __weak DCAAnalyticsController *weakSelf = self;

    [self setAppOpenEvent:^(DNLocalEvent *event) {
        if (![weakSelf wasInfluenced]) {
            [weakSelf recordInfluencedAppOpen:NO];
        }
        [weakSelf setInfluenced:NO];
    }];

    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDNDonkyEventAppOpen handler:[self appOpenEvent]];

    [self setAppCloseEvent:^(DNLocalEvent *event) {
        [weakSelf recordAppClose];
        [weakSelf setInfluenced:NO];
    }];

    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDNDonkyEventAppClose handler:[self appCloseEvent]];

    [self setAppInfluenceEvent:^(DNLocalEvent *event) {
        //We only want to respond to influenced app opens from out Push Controller:
        [weakSelf setInfluenced:YES];
        [weakSelf recordInfluencedAppOpen:YES];
    }];

    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDAEventInfluencedAppOpen handler:[self appInfluenceEvent]];

    //Register Module:
    DNModuleDefinition *analyticsModule = [[DNModuleDefinition alloc] initWithName:NSStringFromClass([self class]) version:kDAAnalyticsVersion];
    [[DNDonkyCore sharedInstance] registerModule:analyticsModule];

}

- (void)stop {
    [[DNDonkyCore sharedInstance] unSubscribeToLocalEvent:kDNDonkyEventAppOpen handler:[self appOpenEvent]];
    [[DNDonkyCore sharedInstance] unSubscribeToLocalEvent:kDNDonkyEventAppClose handler:[self appCloseEvent]];
    [[DNDonkyCore sharedInstance] unSubscribeToLocalEvent:kDAEventInfluencedAppOpen handler:[self appInfluenceEvent]];
}

- (void)recordInfluencedAppOpen:(BOOL)influenced {
    DNInfoLog(@"Recording app open. Was influenced == %d", influenced);
    dispatch_async([self donkyAnalyticsProcessingQueue], ^{
        NSMutableDictionary *appLaunch = [[NSMutableDictionary alloc] init];

        [appLaunch dnSetObject:[[NSDate date] donkyDateForServer] forKey:DALaunchTimeUTC];
        [appLaunch dnSetObject:influenced ? DCANotificationSession : DCANoneSession forKey:DASessionTrigger];
        [appLaunch dnSetObject:kDNMiscOperatingSystem forKey:DAOperatingSystem];

        DNClientNotification *clientNotification = [[DNClientNotification alloc] initWithType:DAAppLaunch
                                                                                         data:appLaunch
                                                                          acknowledgementData:nil];
        [[DNNetworkController sharedInstance] queueClientNotifications:@[clientNotification]];

        //We need to persist this app launch
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:DAAppLaunchDefaults];
    });
}

- (void)recordAppClose {
    DNInfoLog(@"Recording app close.");
    dispatch_async([self donkyAnalyticsProcessingQueue], ^{
        NSDate *startTime = [[NSUserDefaults standardUserDefaults] objectForKey:DAAppLaunchDefaults];
        if (startTime) {
            NSMutableDictionary *appLaunch = [[NSMutableDictionary alloc] init];
            NSDate *endDate = [NSDate date];
            if ([startTime isDateBeforeDate:endDate]) {
                [appLaunch dnSetObject:[startTime donkyDateForServer] forKey:DAStartTimeUTC];
                [appLaunch dnSetObject:[endDate donkyDateForServer] forKey:DAEndTimeUTC];
                [appLaunch dnSetObject:DCANoneSession forKey:DASessionTrigger];
                [appLaunch dnSetObject:kDNMiscOperatingSystem forKey:DAOperatingSystem];

                DNClientNotification *clientNotification = [[DNClientNotification alloc] initWithType:DAAppSession
                                                                                                 data:appLaunch
                                                                                  acknowledgementData:nil];
                [[DNNetworkController sharedInstance] queueClientNotifications:@[clientNotification]];
            }
            else {
                DNErrorLog(@"Cannot report app session as Start date is after the end date ... Start: %@ VS End %@", startTime, endDate);
            }
        }
    });
}

+ (void)recordGeoFenceCrossing:(NSDictionary *)data {
    DNClientNotification *clientNotification = [[DNClientNotification alloc] initWithType:kDCAnalyticsGeoFenceCrossed
                                                                                     data:data
                                                                      acknowledgementData:nil];
    [[DNNetworkController sharedInstance] queueClientNotifications:@[clientNotification]];
}

+ (void)recordGeoFenceTriggerExecuted:(NSDictionary *)data {
    DNClientNotification *clientNotification = [[DNClientNotification alloc] initWithType:kDCAnalyticsGeoFenceTriggered
                                                                                     data:data
                                                                      acknowledgementData:nil];
    [[DNNetworkController sharedInstance] queueClientNotifications:@[clientNotification]];
}

@end
