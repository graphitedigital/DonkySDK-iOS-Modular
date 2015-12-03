//
//  DNDeviceDetailsHelper.m
//  Core Container
//
//  Created by Donky Networks on 16/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DNDeviceDetailsHelper.h"
#import "DNUserDefaultsHelper.h"
#import "DNConstants.h"
#import "DNSystemHelpers.h"

static NSString *const DNDeviceDetailsType = @"DeviceType";
static NSString *const DNDeviceDetailsName = @"DeviceName";
static NSString *const DNDeviceDetailsAdditional = @"AdditionalProperties";

@implementation DNDeviceDetailsHelper

+ (NSString *) deviceType {
    return [DNUserDefaultsHelper objectForKey:DNDeviceDetailsType];
}

+ (NSString *) deviceModel {
    return [[UIDevice currentDevice] localizedModel];
}

+ (NSString *) operatingSystem {
    return kDNMiscOperatingSystem;
}

+ (NSString *) osVersion {
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *) deviceName {
    return [DNUserDefaultsHelper objectForKey:DNDeviceDetailsName];
}

+ (NSDictionary *)additionalProperties {
    return [DNUserDefaultsHelper objectForKey:DNDeviceDetailsAdditional];
}

+ (void)saveDeviceType:(NSString *)deviceType {
    [DNUserDefaultsHelper saveObject:deviceType withKey:DNDeviceDetailsType];
}

+ (void)saveDeviceName:(NSString *)deviceName {
    [DNUserDefaultsHelper saveObject:deviceName withKey:DNDeviceDetailsName];
}

+ (void)saveAdditionalProperties:(NSDictionary *) additionalProperties {
    [DNUserDefaultsHelper saveObject:additionalProperties withKey:DNDeviceDetailsAdditional];
}

@end
