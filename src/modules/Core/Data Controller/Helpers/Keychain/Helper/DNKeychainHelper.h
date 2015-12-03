//
//  DNKeychainHelper.h
//  NAAS Core SDK Container
//
//  Created by Donky Networks on 19/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Security/Security.h>

@interface DNKeychainHelper : NSObject

+ (void)saveObjectToKeychain:(id)object withKey:(NSString *)key;

+ (id)objectForKey:(NSString *)key;

@end
