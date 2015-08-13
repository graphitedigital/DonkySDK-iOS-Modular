//
//  DNClientDetails.m
//  Core Container
//
//  Created by Chris Watson on 17/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNClientDetails.h"
#import "NSDate+DNDateHelper.h"
#import "DNClientDetailsHelper.h"
#import "NSMutableDictionary+DNDictionary.h"

static NSString *const DNDeviceCurrentLocalTime = @"currentLocalTime";
static NSString *const DNDeviceModuleVersions = @"moduleVersions";
static NSString *const DNDeviceAppVersion = @"appVersion";
static NSString *const DNDeviceSdkVersion = @"sdkVersion";

@interface DNClientDetails ()
@property(nonatomic, readwrite) NSString *sdkVersion;
@property(nonatomic, readwrite) NSString *appVersion;
@property(nonatomic, readwrite) NSString *currentLocalTime;
@property(nonatomic, readwrite) NSMutableDictionary *moduleVersions;
@end

@implementation DNClientDetails

- (instancetype) init {
    
    self = [super init];
    
    if (self) {
        
        self.sdkVersion = [DNClientDetailsHelper sdkVersion];
        self.appVersion = [[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleVersionKey];
        self.currentLocalTime = [[NSDate date] donkyDateForServer];
        self.moduleVersions = [DNClientDetailsHelper moduleVersions] ? : [[NSMutableDictionary alloc] init];
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
