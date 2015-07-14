//
//  NSManagedObject+DNHelper.h
//
//  Created by Chris Watson on 16/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.

#import <CoreData/CoreData.h>

@interface NSManagedObject (DNHelper)

+ (instancetype)insertNewInstanceWithContext:(NSManagedObjectContext *)context;

+ (NSEntityDescription *)entityDescriptionWithContext:(NSManagedObjectContext *)context;

+ (NSString *)className;

+ (NSFetchRequest *)fetchRequestWithContext:(NSManagedObjectContext *)context;

+ (instancetype)fetchSingleObjectWithPredicate:(NSPredicate *)predicate withContext:(NSManagedObjectContext *)context;

+ (NSArray *)fetchObjectsWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors withContext:(NSManagedObjectContext *)context;

+ (NSArray *)fetchObjectsWithOffset:(NSUInteger)offset limit:(NSUInteger)limit sortDescriptor:(NSArray *)sortDescriptors withContext:(NSManagedObjectContext *)context;

@end
