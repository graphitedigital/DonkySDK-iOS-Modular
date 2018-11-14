//
//  NSManagedObjectContext+DNHelpers.m
//  NAAS Core SDK Container
//
//  Created by Donky Networks on 23/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "NSManagedObjectContext+DNHelpers.h"
#import "DNLoggingController.h"

@implementation NSManagedObjectContext (DNHelpers)

- (void)saveIfHasChangesWithCompletion:(void(^)(BOOL, NSError *))completion {
    [self performBlock:^{
        @try {
            NSError *error;
            if ([self hasChanges]) {
                [self save:&error];
                if (completion) {
                    completion(YES, error);
                }
            } else {
                if (completion) {
                    completion(NO, error);
                }
            }
        } @catch (NSException * exception) {
            DNErrorLog(@"Fatal exception caught: %@", [exception description]);
            [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil];
        }
    }];
}

@end
