//
//  NSManagedObjectContext+DNDelete.m
//  NAAS Core SDK Container
//
//  Created by Donky Networks on 23/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "NSManagedObjectContext+DNDelete.h"
#import "DNLoggingController.h"

@implementation NSManagedObjectContext (DNDelete)

- (void)deleteAllObjectsInArray:(NSArray *)array {
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        @try {
            [self deleteObject:obj];
        }
        @catch (NSException *exception) {
            DNErrorLog(@"Fatal exception caught: %@", [exception description]);
            [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil];
        }
    }];
}

@end
