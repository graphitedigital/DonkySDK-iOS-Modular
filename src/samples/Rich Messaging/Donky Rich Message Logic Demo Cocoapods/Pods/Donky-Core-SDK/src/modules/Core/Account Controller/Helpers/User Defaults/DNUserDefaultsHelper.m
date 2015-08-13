//
//  DNUserDefaultsHelper.m
//  Core Container
//
//  Created by Chris Watson on 15/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNUserDefaultsHelper.h"

@implementation DNUserDefaultsHelper

+ (NSUserDefaults *)userDetails {
    return [NSUserDefaults standardUserDefaults];
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
        NSLog(@"%@", [exception description]);
    }
}

+ (void)resetUserDefaults {
    NSString *domainName = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:domainName];
}

+ (void)saveUserDefaults {
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
