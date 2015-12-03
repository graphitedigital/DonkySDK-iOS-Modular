//
//  DNKeychainItemWrapper.h
//  NAAS Core SDK Container
//
//  Created by Donky Networks on 19/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DNKeychainItemWrapper : NSObject

+ (void)setObject:(id)object forKey:(NSString *)key;

+ (id)objectForKey:(NSString *)key;

@end