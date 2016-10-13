//
//  DRLogicMainControllerHelper.h
//  RichInbox
//
//  Created by Donky Networks on 13/10/2016.
//  Copyright (c) 2016 Donky Networks. All rights reserved.
//

#import "DRDispatch+Reentrant.h"

static const void * const kRecursiveKey = (const void*)&kRecursiveKey;

dispatch_recursive_queue_t dispatch_queue_create_recursive_serial(const char * name) {
    dispatch_queue_t queue = dispatch_queue_create(name, DISPATCH_QUEUE_SERIAL);
    dispatch_queue_set_specific(queue, kRecursiveKey, (__bridge void *)(queue), NULL);
    return queue;
}

void dispatch_sync_recursive(dispatch_recursive_queue_t queue, dispatch_block_t block) {
    if (dispatch_get_specific(kRecursiveKey) == (__bridge void *)(queue)) {
        block();
    }
    else {
        dispatch_sync(queue, block);
    }
}
