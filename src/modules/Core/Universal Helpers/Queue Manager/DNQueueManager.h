//
//  DNQueueManager.h
//  ChatUI
//
//  Created by Chris Watson on 23/11/2015.
//  Copyright © 2015 Chris Wunsch. All rights reserved.
//

#ifndef DNQueueManager_h
#define DNQueueManager_h

#import <Foundation/Foundation.h>
#import <dispatch/queue.h>
#import <dispatch/once.h>
#import <dispatch/object.h>

static dispatch_queue_t donky_network_processing_queue() {
    static dispatch_once_t queueCreationGuard;
    static dispatch_queue_t queue;
    dispatch_once(&queueCreationGuard, ^{
        queue = dispatch_queue_create("com.donky.sdk.network.processing.queue", nil);
    });
    return queue;
}

static dispatch_queue_t donky_network_signal_r_queue() {
    static dispatch_once_t queueCreationGuard;
    static dispatch_queue_t queue;
    dispatch_once(&queueCreationGuard, ^{
        queue = dispatch_queue_create("com.donky.sdk.network.signalR.queue", nil);
    });
    return queue;
}

static dispatch_queue_t donky_logic_processing_queue() {
    static dispatch_once_t queueCreationGuard;
    static dispatch_queue_t queue;
    dispatch_once(&queueCreationGuard, ^{
        queue = dispatch_queue_create("com.donky.sdk.network.processing.queue", nil);
    });
    return queue;
}

#endif
