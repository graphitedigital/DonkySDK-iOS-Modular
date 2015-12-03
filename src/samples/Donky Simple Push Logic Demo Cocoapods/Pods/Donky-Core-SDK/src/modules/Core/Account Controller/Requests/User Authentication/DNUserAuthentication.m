//
//  DNUserAuthentication.m
//  NAAS Core SDK Container
//
//  Created by Donky Networks on 03/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DNUserAuthentication.h"
#import "NSMutableDictionary+DNDictionary.h"
#import "DNConstants.h"
#import "DNAppSettingsController.h"
#import "DNDonkyNetworkDetails.h"

static NSString *const DNNetworkID = @"networkId";
static NSString *const DNDeviceSecret = @"deviceSecret";
static NSString *const DNOperatingSystem = @"operatingSystem";
static NSString *const DNSDKVersion = @"sdkVersion";

@implementation DNUserAuthentication

- (instancetype)init {

    self = [super init];

    if (self) {

    }

    return self;

}

- (NSDictionary *)parameters {

    if (![DNDonkyNetworkDetails networkId]) {
        return nil;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];

    [params dnSetObject:[DNDonkyNetworkDetails networkId] forKey:DNNetworkID];
    [params dnSetObject:[DNDonkyNetworkDetails deviceSecret] forKey:DNDeviceSecret];
    [params dnSetObject:kDNMiscOperatingSystem forKey:DNOperatingSystem];
    [params dnSetObject:[DNAppSettingsController sdkVersion] forKey:DNSDKVersion];

    return params;
}


@end
