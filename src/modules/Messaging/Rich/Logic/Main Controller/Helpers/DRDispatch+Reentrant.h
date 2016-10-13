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

dispatch_recursive_queue_t dispatch_queue_create_recursive_serial(const char * name);

void dispatch_sync_recursive(dispatch_recursive_queue_t queue, dispatch_block_t block);

NS_ASSUME_NONNULL_END
