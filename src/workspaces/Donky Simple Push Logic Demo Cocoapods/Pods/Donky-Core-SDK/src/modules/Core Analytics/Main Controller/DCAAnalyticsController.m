//
//  DCAAnalyticsController.m
//  DonkyCoreAnalytics
//
//  Created by Chris Watson on 01/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DCAAnalyticsController.h"
#import "DNLocalEvent.h"
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

@interface DCAAnalyticsController ()
@property(nonatomic, getter=wasInfluenced) BOOL influenced;
@property(nonatomic, copy) void (^appOpenEvent)(DNLocalEvent *);
@property(nonatomic, copy) void (^appCloseEvent)(DNLocalEvent *);
@property(nonatomic, copy) void (^appInfluenceEvent)(DNLocalEvent *);
@end

@implementation DCAAnalyticsController

+(DCAAnalyticsController *)sharedInstance
{
    static dispatch_once_t pred;
    static DCAAnalyticsController *sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[DCAAnalyticsController alloc] initPrivate];
    });
    
    return sharedInstance;
}

-(instancetype)initPrivate
{

    self = [super init];
    
    if (self) {

    }

    return self;
}

- (instancetype) init {
    return [self initPrivate];
}

- (void) start {
    __weak DCAAnalyticsController *weakSelf = self;

    self.appOpenEvent = ^(DNLocalEvent *event) {
        if (![weakSelf wasInfluenced])
            [weakSelf recordInfluencedAppOpen:NO];
        [weakSelf setInfluenced:NO];
    };

    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDNDonkyEventAppOpen handler:self.appOpenEvent];

    self.appCloseEvent = ^(DNLocalEvent *event) {
        [weakSelf recordAppClose];
    };

    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDNDonkyEventAppClose handler:self.appCloseEvent];

    self.appInfluenceEvent = ^(DNLocalEvent *event) {
        //We only want to respond to influenced app opens from out Push Controller:
        [weakSelf setInfluenced:YES];
        [weakSelf recordInfluencedAppOpen:YES];
    };

    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDAEventInfluencedAppOpen handler:self.appInfluenceEvent];
    
    //Register Module:
    DNModuleDefinition *analyticsModule = [[DNModuleDefinition alloc] initWithName:NSStringFromClass([self class]) version:kDAAnalyticsVersion];
    [[DNDonkyCore sharedInstance] registerModule:analyticsModule];
}

- (void)stop {
    [[DNDonkyCore sharedInstance] unSubscribeToLocalEvent:kDNDonkyEventAppOpen handler:self.appOpenEvent];
    [[DNDonkyCore sharedInstance] unSubscribeToLocalEvent:kDNDonkyEventAppClose handler:self.appCloseEvent];
    [[DNDonkyCore sharedInstance] unSubscribeToLocalEvent:kDAEventInfluencedAppOpen handler:self.appInfluenceEvent];
}

- (void)recordInfluencedAppOpen:(BOOL)influenced {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSMutableDictionary *appLaunch = [[NSMutableDictionary alloc] init];

        [appLaunch dnSetObject:[[NSDate date] donkyDateForServer] forKey:DALaunchTimeUTC];
        [appLaunch dnSetObject:influenced ? @"Notification" : @"None" forKey:DASessionTrigger];
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSDate *startTime = [[NSUserDefaults standardUserDefaults] objectForKey:DAAppLaunchDefaults];
        if (startTime) {
            NSMutableDictionary *appLaunch = [[NSMutableDictionary alloc] init];
            NSDate *endDate = [NSDate date];
            if ([startTime isDateBeforeDate:endDate]) {
                [appLaunch dnSetObject:[startTime donkyDateForServer] forKey:DAStartTimeUTC];
                [appLaunch dnSetObject:[endDate donkyDateForServer] forKey:DAEndTimeUTC];
                [appLaunch dnSetObject:@"None" forKey:DASessionTrigger];
                [appLaunch dnSetObject:kDNMiscOperatingSystem forKey:DAOperatingSystem];

                DNClientNotification *clientNotification = [[DNClientNotification alloc] initWithType:DAAppSession
                                                                                                 data:appLaunch
                                                                                  acknowledgementData:nil];
                [[DNNetworkController sharedInstance] queueClientNotifications:@[clientNotification]];
            }
            else
                DNErrorLog(@"Cannot report app session as Start date is after the end date ... Start: %@ VS End %@", startTime, endDate);
        }
    });
}

@end
