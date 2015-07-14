//
//  NSManagedObjectContext+DNDelete.m
//  NAAS Core SDK Container
//
//  Created by Chris Watson on 23/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "NSManagedObjectContext+DNDelete.h"
#import "DNLoggingController.h"

@implementation NSManagedObjectContext (DNDelete)

- (void)deleteAllObjectsInArray:(NSArray *)array {
    @synchronized (self) {
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
}

@end
