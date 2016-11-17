//
//  DNAppSettingsController.m
//  NAAS Core SDK Container
//
//  Created by Donky Networks on 16/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DNAppSettingsController.h"
#import "DNFileHelpers.h"
#import "DNConstants.h"

@implementation DNAppSettingsController

+ (NSDictionary *)donkyConfigurationPlist {
    NSBundle *bundle = [NSBundle bundleForClass:[DNAppSettingsController class]];
    return [[NSDictionary alloc] initWithContentsOfFile:[bundle pathForResource:kDNConfigPlistFileName ofType:@"plist"]];
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
