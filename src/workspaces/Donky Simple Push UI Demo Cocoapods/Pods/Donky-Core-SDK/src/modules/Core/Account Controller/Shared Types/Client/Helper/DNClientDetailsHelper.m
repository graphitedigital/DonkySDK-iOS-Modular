//
//  DNClientDetailsHelper.m
//  Core Container
//
//  Created by Chris Watson on 17/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

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
