//
//  DNClientDetails.m
//  Core Container
//
//  Created by Donky Networks on 17/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DNClientDetails.h"
#import "NSDate+DNDateHelper.h"
#import "DNClientDetailsHelper.h"
#import "NSMutableDictionary+DNDictionary.h"

static NSString *const DNDeviceCurrentLocalTime = @"currentLocalTime";
static NSString *const DNDeviceModuleVersions = @"moduleVersions";
static NSString *const DNDeviceAppVersion = @"appVersion";
static NSString *const DNDeviceSdkVersion = @"sdkVersion";

@interface DNClientDetails ()
@property (nonatomic, readwrite) NSString *sdkVersion;
@property (nonatomic, readwrite) NSString *appVersion;
@property (nonatomic, readwrite) NSString *currentLocalTime;
@property (nonatomic, readwrite) NSMutableDictionary *moduleVersions;
@end

@implementation DNClientDetails

- (instancetype) init {
    
    self = [super init];
    
    if (self) {

        [self setSdkVersion:[DNClientDetailsHelper sdkVersion]];
        [self setAppVersion:[[NSBundle bundleForClass:[self class]] infoDictionary][(NSString *)kCFBundleVersionKey]];
        [self setCurrentLocalTime:[[NSDate date] donkyDateForServer]];
        [self setModuleVersions:[DNClientDetailsHelper moduleVersions] ? : [[NSMutableDictionary alloc] init]];
    }

    return self;
}

- (void)saveModuleVersions:(NSMutableDictionary *)moduleVersions {
    [DNClientDetailsHelper saveModuleVersions:moduleVersions];
}

- (NSDictionary *) parameters {

    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];

    [parameters dnSetObject:[self sdkVersion] forKey:DNDeviceSdkVersion];
    [parameters dnSetObject:[self appVersion] forKey:DNDeviceAppVersion];
    [parameters dnSetObject:[self currentLocalTime] forKey:DNDeviceCurrentLocalTime];
    [parameters dnSetObject:[self moduleVersions] forKey:DNDeviceModuleVersions];

    return parameters;
}

@end
