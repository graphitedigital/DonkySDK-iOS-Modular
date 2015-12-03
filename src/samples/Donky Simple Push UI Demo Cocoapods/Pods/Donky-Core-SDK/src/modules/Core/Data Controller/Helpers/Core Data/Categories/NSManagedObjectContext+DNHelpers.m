//
//  NSManagedObjectContext+DNHelpers.m
//  NAAS Core SDK Container
//
//  Created by Donky Networks on 23/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "NSManagedObjectContext+DNHelpers.h"
#import "DNLoggingController.h"

@implementation NSManagedObjectContext (DNHelpers)

-(BOOL)saveIfHasChanges:(NSError *__autoreleasing*)error {
        @synchronized (self) {
            @try {
            if ([self hasChanges]) {
                return [self save:error];
            }
            return YES;
        }
        @catch (NSException * exception)
        {
            DNErrorLog(@"Fatal exception caught: %@", [exception description]);
            [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil];
        }
    }
    return NO;
}

@end
