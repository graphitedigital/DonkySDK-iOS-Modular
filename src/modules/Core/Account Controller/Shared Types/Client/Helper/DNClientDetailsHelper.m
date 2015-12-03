//
//  DNClientDetailsHelper.m
//  Core Container
//
//  Created by Donky Networks on 17/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DNClientDetailsHelper.h"
#import "DNAppSettingsController.h"
#import "DNUserDefaultsHelper.h"

static NSString *const DNModuleVersions = @"ModuleVersions";

@implementation DNClientDetailsHelper

+ (NSString *)sdkVersion {
    return [DNAppSettingsController sdkVersion];
}

+ (NSMutableDictionary *)moduleVersions {
    return [[DNUserDefaultsHelper objectForKey:DNModuleVersions] mutableCopy];
}

+ (void)saveModuleVersions:(NSMutableDictionary *)moduleVersions {
    [DNUserDefaultsHelper saveObject:moduleVersions withKey:DNModuleVersions];
}

@end
