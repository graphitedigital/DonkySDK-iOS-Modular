//
//  DNAppSettingsController.m
//  NAAS Core SDK Container
//
//  Created by Chris Watson on 16/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNAppSettingsController.h"
#import "DNFileHelpers.h"
#import "DNConstants.h"

@implementation DNAppSettingsController

+ (NSDictionary *)donkyConfigurationPlist {
    return [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kDNConfigPlistFileName ofType:@"plist"]];
}

+ (NSString *)sdkVersion {
    return [DNAppSettingsController donkyConfigurationPlist][kDNConfigSDKVersion];
}

+ (NSDictionary *)donkyLoggingOptions {
    return [DNAppSettingsController donkyConfigurationPlist][kDNConfigLoggingOptions];
}

+ (BOOL)displayNoInternetAlert {
    return [[DNAppSettingsController donkyConfigurationPlist][kDNConfigDisplayNoInternetAlert] boolValue];
}

+ (BOOL)loggingEnabled {
    return [[DNAppSettingsController donkyLoggingOptions][kDNConfigLoggingEnabled] boolValue];
}

+ (BOOL)outputWarningLogs {
    return [[DNAppSettingsController donkyLoggingOptions][kDNConfigOutputWarningLogs] boolValue];
}

+ (BOOL)outputErrorLogs {
    return [[DNAppSettingsController donkyLoggingOptions][kDNConfigOutputErrorLogs] boolValue];
}

+ (BOOL)outputInfoLogs {
    return [[DNAppSettingsController donkyLoggingOptions][kDNConfigOutputInfoLogs] boolValue];
}

+ (BOOL)outputDebugLogs {
    return [[DNAppSettingsController donkyLoggingOptions][kDNConfigOutputDebugLogs] boolValue];
}

+ (BOOL)outputSensitiveLogs {
    return [[DNAppSettingsController donkyLoggingOptions][kDNConfigOutputSensitiveLogs] boolValue];
}

+ (NSInteger)debugLogSubmissionInterval {
    return [[DNAppSettingsController donkyConfigurationPlist][kDNDebugLogSubmissionInterval] integerValue];
}


@end
