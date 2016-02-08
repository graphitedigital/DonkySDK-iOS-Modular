//
//  NSDictionary+DKDictionary.m
//  NAAS Core SDK Container
//
//  Created by Donky Networks on 19/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "NSMutableDictionary+DNDictionary.h"
#import "DNLoggingController.h"

@implementation NSMutableDictionary (DNDictionary)

- (void)dnSetObject:(id)object forKey:(id<NSCopying>)key
{
    if (object) {
        @try {
            if ([self isKindOfClass:[NSMutableDictionary class]])
                self[key] = object;
            else
                DNInfoLog(@"Not a mutable dictionary. Check input");
        }
        @catch (NSException *exception) {
            DNErrorLog(@"Fatal, %@", [exception description]);
            [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil];
        }
    }
}

- (NSMutableDictionary *)donkyRemoveNullValues
{
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (obj == [NSNull null])
            [self removeObjectForKey:key];
        else if ([obj isKindOfClass:[NSMutableDictionary class]])
            [obj donkyRemoveNullValues];
    }];

    return self;
}

@end
