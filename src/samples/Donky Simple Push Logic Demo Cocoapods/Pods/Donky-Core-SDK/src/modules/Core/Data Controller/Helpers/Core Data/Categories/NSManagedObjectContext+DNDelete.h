//
//  NSManagedObjectContext+DNDelete.h
//  NAAS Core SDK Container
//
//  Created by Chris Watson on 23/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (DNDelete)

- (void) deleteAllObjectsInArray:(NSArray *)array;

@end
