//
//  DRLogicMainControllerHelper.h
//  RichInbox
//
//  Created by Donky Networks on 13/10/2016.
//  Copyright (c) 2016 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef dispatch_queue_t dispatch_recursive_queue_t;

NS_ASSUME_NONNULL_BEGIN

/**
 Creates a serial dispatch queue than can safely be called reentrantly using dispatch_sync_recursive.

 @param name Unique name of a queue

 @return queue
 */
dispatch_recursive_queue_t dispatch_queue_create_recursive_serial(const char * name);

/**
 Performs dispatch_sync on a queue, but allows it to be called reentrantly without deadlocking.
 
 This function is intended to be used with queues created with
 dispatch_queue_create_recursive_serial(const char * name).

 @param queue queue
 @param block block
 */
void dispatch_sync_recursive(dispatch_recursive_queue_t queue, dispatch_block_t block);

NS_ASSUME_NONNULL_END
