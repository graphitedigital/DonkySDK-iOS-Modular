//
//  DNUserDefaultsHelper.m
//  Donky COreSDK
//
//  Created by Donky Networks on 15/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DNUserDefaultsHelper.h"
#import "DNLoggingController.h"

@implementation DNUserDefaultsHelper

+ (NSUserDefaults *)userDetails {
     NSString *domainName = [[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@"com.dynmark.donkyuserdefaults"];
    return [[NSUserDefaults alloc] initWithSuiteName:domainName];
}

+ (void)saveObject:(id)object withKey:(NSString *) key {
    [[DNUserDefaultsHelper userDetails] setObject:object forKey:key];
    [DNUserDefaultsHelper saveUserDefaults];
}

+ (id)objectForKey:(NSString *) key {
    @try {
          return [[DNUserDefaultsHelper userDetails] objectForKey:key];
    }
    @catch (NSException *exception) {
        DNErrorLog(@"%@", [exception description]);
    }
}

+ (void)resetUserDefaults {
    NSString *domainName = [[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@"com.dynmark.donkyuserdefaults"];
    [[DNUserDefaultsHelper userDetails] removeSuiteNamed:domainName];
}

+ (void)saveUserDefaults {
    [[DNUserDefaultsHelper userDetails] synchronize];
}

@end
