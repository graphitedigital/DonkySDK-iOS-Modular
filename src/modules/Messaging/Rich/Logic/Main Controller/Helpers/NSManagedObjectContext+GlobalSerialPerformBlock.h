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

/*!
 Asynchronously performs the block on the context's queue.
 It mimics the behaviour of -[NSManagedObjectContext performBlock:], but executes only one block at a time, despite
 which context it was submitted to.
 
 The reason behind this method is that, due to (supposedly) implementation detail change in Core Data, performBlock:
 behaves slightly differently than it used to.
 Pre-iOS 10 performBlock: seems to have executed blocks serially, despite being submitted to different queues.
 On iOS 10 it seems that each NSManagedObjectContext has it's own queue.
 
 This was never a correct assumption to make, especially when documentation states that performBlock: "asynchronously 
 performs the block on the _context's_ queue". However, there are places in the SDK where the change of this behaviour
 in iOS 10 caused some race condition bugs to pop up. This method is intended to act as a drop-in replacement to keep
 the behaviour from before iOS 10.
 
 @param block The block to perform.
 
 @since 2.8.3.0
 */
- (void)dr_performBlockUsingManagedObjectContextsGlobalSerialQueue:(void (^)())block;
@end

NS_ASSUME_NONNULL_END
