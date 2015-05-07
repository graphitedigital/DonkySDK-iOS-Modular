//
//  NSManagedObject+DNHelper.m
//
//  Created by Chris Watson on 16/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.

#import "NSManagedObject+DNHelper.h"
#import "DNLoggingController.h"

@implementation NSManagedObject (DNHelper)

+ (instancetype)insertNewInstanceWithContext:(NSManagedObjectContext *) context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self className] inManagedObjectContext:context];
}

+ (NSEntityDescription *)entityDescriptionWithContext:(NSManagedObjectContext *) context
{
    return [NSEntityDescription entityForName:[self className] inManagedObjectContext:context] ;
}

+ (NSString *) className
{
    return NSStringFromClass([self class]);
}

+(NSFetchRequest *)fetchRequestWithContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [self entityDescriptionWithContext:context];
    
    return request;
}

+ (instancetype)fetchSingleObjectWithPredicate:(NSPredicate *)predicate withContext:(NSManagedObjectContext *)context {

    NSFetchRequest *request = [self fetchRequestWithContext:context];
    request.predicate = predicate;
    request.sortDescriptors = @[];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];

    if (error)
        DNDebugLog(@"Problem fetching request: %@\nError: %@", request, error);
    
    if ([results count]) {
        //purely for debug logging, this should never happen unless integrators manually create a device user object. DON'T DO THIS!
        if ([results count] > 1)
            DNDebugLog(@"Fetched more than one object: %@\nRequest: %@. Returning first.", results, request);
        return [results firstObject];
    }

    return nil;
}

+ (NSArray *)fetchObjectsWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors withContext:(NSManagedObjectContext *)context {

    NSFetchRequest *request = [self fetchRequestWithContext:context];
    request.predicate = predicate;
    request.sortDescriptors = sortDescriptors;

    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];

    if (error)
        DNDebugLog(@"Problem fetching request: %@\nError: %@", request, error);

    return results;
}


@end
