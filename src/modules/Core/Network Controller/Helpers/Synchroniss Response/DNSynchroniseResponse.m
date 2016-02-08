//
//  DNSynchroniseResponse.m
//  Donky Network SDK Container
//
//  Created by Donky Networks on 09/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DNSynchroniseResponse.h"
#import "DNLoggingController.h"

@interface DNSynchroniseResponse ()
@property (nonatomic, readwrite) BOOL moreNotificationsAvailable;
@property (nonatomic, readwrite) NSArray *failedClientNotifications;
@property (nonatomic, readwrite) NSArray *serverNotifications;
@end

static NSString *DNFailedClientNotifications = @"failedClientNotifications";
static NSString *DNServerNotifications = @"serverNotifications";
static NSString *DNMoreNotificationsAvailable = @"moreNotificationsAvailable";

@implementation DNSynchroniseResponse

- (instancetype) initWithDonkyNetworkResponse:(NSDictionary *)response {

    self = [super init];

    if (self) {

        @try {
            [self setServerNotifications:response[DNServerNotifications]];
            [self setFailedClientNotifications:response[DNFailedClientNotifications]];
            [self setMoreNotificationsAvailable:[response[DNMoreNotificationsAvailable] boolValue]];
        }
        @catch (NSException *exception) {
            DNErrorLog(@"Fatal exception (%@) when processing network response.... Reporting & Continuing", [exception description]);
            [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil]; //Immediately submit to network
            [self setServerNotifications:nil];
            [self setFailedClientNotifications:nil];
            [self setMoreNotificationsAvailable:NO];
        }
    }

    return self;
}

@end
