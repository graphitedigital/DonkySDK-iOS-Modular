//
//  DNQueueManager.h
//  ChatUI
//
//  Created by Chris Watson on 23/11/2015.
//  Copyright © 2015 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <dispatch/queue.h>
#import <dispatch/once.h>
#import <dispatch/object.h>

__attribute__((unused)) static const dispatch_queue_t donky_network_processing_queue() {
    static dispatch_once_t queueCreationGuard;
    static dispatch_queue_t queue;
    dispatch_once(&queueCreationGuard, ^{
        queue = dispatch_queue_create("com.donky.sdk.network.processing.queue", nil);
    });
    return queue;
}

__attribute__((unused)) static const dispatch_queue_t donky_network_signal_r_queue() {
    static dispatch_once_t queueCreationGuard;
    static dispatch_queue_t queue;
    dispatch_once(&queueCreationGuard, ^{
        queue = dispatch_queue_create("com.donky.sdk.network.signalR.queue", nil);
    });
    return queue;
}

__attribute__((unused)) static const dispatch_queue_t donky_logic_processing_queue() {
    static dispatch_once_t queueCreationGuard;
    static dispatch_queue_t queue;
    dispatch_once(&queueCreationGuard, ^{
        queue = dispatch_queue_create("com.donky.sdk.network.processing.queue", nil);
    });
    return queue;
}
