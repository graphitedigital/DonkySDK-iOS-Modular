//
//  DNUserDefaultsHelper.h
//  Core Container
//
//  Created by Chris Watson on 15/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DNUserDefaultsHelper : NSObject

+ (void)saveObject:(id)object withKey:(NSString *)key;

+ (id)objectForKey:(NSString *)key;

+ (void)resetUserDefaults;

+ (void)saveUserDefaults;

@end
