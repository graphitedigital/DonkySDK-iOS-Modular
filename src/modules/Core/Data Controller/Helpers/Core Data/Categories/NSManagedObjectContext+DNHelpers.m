//
//  NSManagedObjectContext+DNHelpers.m
//  NAAS Core SDK Container
//
//  Created by Chris Watson on 23/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "NSManagedObjectContext+DNHelpers.h"

@implementation NSManagedObjectContext (DNHelpers)

-(BOOL)saveIfHasChanges:(NSError *__autoreleasing*)error {
    if ([self hasChanges])
        return [self save:error];
    return YES;
}

@end
