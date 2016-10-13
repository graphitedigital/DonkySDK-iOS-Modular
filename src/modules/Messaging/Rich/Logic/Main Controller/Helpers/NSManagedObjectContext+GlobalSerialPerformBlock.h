//
//  DRLogicMainControllerHelper.h
//  RichInbox
//
//  Created by Donky Networks on 13/10/2016.
//  Copyright (c) 2016 Donky Networks. All rights reserved.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSManagedObjectContext (GlobalSerialPerformBlock)
- (void)dr_performBlockUsingManagedObjectContextsGlobalSerialQueue:(void (^)())block;
@end

NS_ASSUME_NONNULL_END
