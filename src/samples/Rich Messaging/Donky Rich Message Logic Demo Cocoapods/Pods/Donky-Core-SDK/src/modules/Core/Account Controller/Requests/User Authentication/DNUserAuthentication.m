//
//  DNUserAuthentication.m
//  NAAS Core SDK Container
//
//  Created by Chris Watson on 03/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

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

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];

    [params dnSetObject:[DNDonkyNetworkDetails networkId] forKey:DNNetworkID];
    [params dnSetObject:[DNDonkyNetworkDetails deviceSecret] forKey:DNDeviceSecret];
    [params dnSetObject:kDNMiscOperatingSystem forKey:DNOperatingSystem];
    [params dnSetObject:[DNAppSettingsController sdkVersion] forKey:DNSDKVersion];

    return params;
}


@end
