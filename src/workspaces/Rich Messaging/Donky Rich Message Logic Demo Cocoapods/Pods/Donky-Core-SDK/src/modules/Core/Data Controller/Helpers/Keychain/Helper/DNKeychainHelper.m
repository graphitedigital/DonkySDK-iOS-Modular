//
//  DNKeychainHelper.m
//  NAAS Core SDK Container
//
//  Created by Chris Watson on 19/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNKeychainHelper.h"
#import "DNKeychainItemWrapper.h"
#import "DNConstants.h"

@implementation DNKeychainHelper

+ (void)saveObjectToKeychain:(id) object withKey:(NSString *) key {
    [DNKeychainItemWrapper setObject:object forKey:key];
}

+ (id)objectForKey:(NSString *) key {
    return [DNKeychainItemWrapper objectForKey:key];
}


@end
