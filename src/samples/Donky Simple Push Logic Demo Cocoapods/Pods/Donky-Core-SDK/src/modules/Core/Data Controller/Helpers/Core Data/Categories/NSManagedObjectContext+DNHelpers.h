//
//  NSManagedObjectContext+DNHelpers.h
//  NAAS Core SDK Container
//
//  Created by Donky Networks on 23/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (DNHelpers)

- (BOOL)saveIfHasChanges:(NSError *__autoreleasing*)error;

@end
