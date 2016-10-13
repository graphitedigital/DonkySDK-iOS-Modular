//
//  DRLogicMainControllerHelper.h
//  RichInbox
//
//  Created by Donky Networks on 13/10/2016.
//  Copyright (c) 2016 Donky Networks. All rights reserved.
//

#import "NSManagedObjectContext+GlobalSerialPerformBlock.h"
#import "DRDispatch+Reentrant.h"

@implementation NSManagedObjectContext (GlobalSerialPerformBlock)

- (void)dr_performBlockUsingManagedObjectContextsGlobalSerialQueue:(void (^)())block {
    static dispatch_recursive_queue_t managedObjectContextGlobalQueue;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        const char * queueName = "com.donkySDK.NSManagedObjectContextsQueue";
        managedObjectContextGlobalQueue = dispatch_queue_create_recursive_serial(queueName);
    });
    
    dispatch_sync_recursive(managedObjectContextGlobalQueue, ^{
        [self performBlockAndWait:block];
    });
}

@end
