//
//  NSManagedObject+DNHelper.m
//
//  Created by Donky Networks on 16/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.

#import "NSManagedObject+DNHelper.h"
#import "DNLoggingController.h"
#import "NSManagedObjectContext+DNDelete.h"

@implementation NSManagedObject (DNHelper)

+ (instancetype)insertNewInstanceWithContext:(NSManagedObjectContext *) context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self className] inManagedObjectContext:context];
}

+ (NSEntityDescription *)entityDescriptionWithContext:(NSManagedObjectContext *) context
{
    return [NSEntityDescription entityForName:[self className] inManagedObjectContext:context] ;
}

+ (NSString *)className
{
    return NSStringFromClass([self class]);
}

+(NSFetchRequest *)fetchRequestWithContext:(NSManagedObjectContext *)context
{
    @try {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[self entityDescriptionWithContext:context]];

        return request;
    }
    @catch (NSException *exception) {
        DNErrorLog(@"Fatal exception (%@) when processing network response.... Reporting & Continuing", [exception description]);
        [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil]; //Immediately submit to network
    }

    return nil;
}

+ (NSFetchRequest *)fetchRequestWithContext:(NSManagedObjectContext *)context batchSize:(NSUInteger)batch offset:(NSUInteger)offset {
    @try {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setFetchBatchSize:batch];
        if (offset > 0) {
            [request setFetchOffset:offset];
        }
        [request setEntity:[self entityDescriptionWithContext:context]];

        return request;
    }
    @catch (NSException *exception) {
        DNErrorLog(@"Fatal exception (%@) when processing network response.... Reporting & Continuing", [exception description]);
        [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil]; //Immediately submit to network
    }

    return nil;
}

+ (instancetype)fetchSingleObjectWithPredicate:(NSPredicate *)predicate withContext:(NSManagedObjectContext *)context includesPendingChanges:(BOOL)pendingChanges {
   @try {
       NSFetchRequest *request = [self fetchRequestWithContext:context];
       [request setIncludesPendingChanges:pendingChanges];
       [request setPredicate:predicate];
       [request setSortDescriptors:@[]];

       NSError *error;
       NSArray *results = [context executeFetchRequest:request error:&error];

       if (error) {
           DNDebugLog(@"Problem fetching request: %@\nError: %@", request, error);
       }

       if ([results count]) {
           if ([results count] > 1) {
               DNDebugLog(@"Fetched more than one object: %@\nCleaning data...", results);
               //Cleaing dupes:
               NSMutableArray *delete = [results mutableCopy];
               [delete removeObject:[results lastObject]];
               [context deleteAllObjectsInArray:delete];
           }
           return [results lastObject];
       }

       return nil;
   }
   @catch (NSException *exception) {
       DNErrorLog(@"Fatal exception (%@) when processing network response.... Reporting & Continuing", [exception description]);
       [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil]; //Immediately submit to network
   }
   return nil;
}

+ (NSArray *)fetchObjectsWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors withContext:(NSManagedObjectContext *)context {

    @try {
        NSFetchRequest *request = [self fetchRequestWithContext:context];
        if (predicate) {
            [request setPredicate:predicate];
        }
        [request setSortDescriptors:sortDescriptors];

        NSError *error;
        NSArray *results = [context executeFetchRequest:request error:&error];

        if (error) {
            DNDebugLog(@"Problem fetching request: %@\nError: %@", request, error);
        }

        return results;
    }
    @catch (NSException *exception) {
        DNErrorLog(@"Fatal exception (%@) when processing network response.... Reporting & Continuing", [exception description]);
        [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil]; //Immediately submit to network
    }

    return nil;
}

+ (NSArray *)fetchObjectsWithOffset:(NSUInteger)offset limit:(NSUInteger)limit sortDescriptor:(NSArray *)sortDescriptors withContext:(NSManagedObjectContext *)context {

    @try {
        NSFetchRequest *request = [self fetchRequestWithContext:context];
        [request setFetchOffset:offset];
        [request setFetchLimit:limit];
        [request setSortDescriptors:sortDescriptors];

        NSError *error;
        NSArray *results = [context executeFetchRequest:request error:&error];

        if (error)
            DNDebugLog(@"Problem fetching request: %@\nError: %@", request, error);

        return results;
    }
    @catch (NSException *exception) {
        DNErrorLog(@"Fatal exception (%@) when processing network response.... Reporting & Continuing", [exception description]);
        [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil]; //Immediately submit to network
    }

    return nil;
}

@end
