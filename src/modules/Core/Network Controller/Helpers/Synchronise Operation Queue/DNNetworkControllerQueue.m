//
//  DNNetworkControllerQueue.m
//  ChatUI
//
//  Created by Donky Networks on 24/09/2015.
//  Copyright © 2015 Donky Networks. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DNNetworkControllerQueue.h"
#import "DNNetworkOperation.h"
#import "DNLoggingController.h"
#import "DNErrorController.h"
#import "DNDonkyCore.h"
#import "DNConstants.h"
#import "DNSystemHelpers.h"

@interface DNNetworkControllerQueue ()
@property(nonatomic, copy) DNLocalEventHandler appCloseEvent;
@end

@implementation DNNetworkControllerQueue

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        [self setName:NSStringFromClass([self class])];
        [self setMaxConcurrentOperationCount:1];
        
        static dispatch_once_t queueCreationGuard;
        static dispatch_queue_t queue;
        dispatch_once(&queueCreationGuard, ^{
            queue = dispatch_queue_create("com.donky.NetworkQueue", 0);
        });
        
        if ([DNSystemHelpers systemVersionAtLeast:8.0]) {
            [self setUnderlyingQueue:queue];
        }
        
        __weak __typeof(self) weakSelf = self;
        
        [self setAppCloseEvent:^(DNLocalEvent *event) {
            [[weakSelf operations] enumerateObjectsUsingBlock:^(__kindof NSOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DNNetworkOperation *operation = obj;
                [operation cancel];
            }];
        }];
        
        [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDNDonkyEventAppClose handler:[self appCloseEvent]];
    }
    
    return self;
}

- (BOOL)synchroniseWithParams:(NSDictionary *)params successBlock:(DNNetworkSuccessBlock)success failureBlock:(DNNetworkFailureBlock)failure {
    
    __block BOOL isSyncRunning = NO;
    [[self operations] enumerateObjectsUsingBlock:^(__kindof NSOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DNNetworkOperation *operation = obj;
        if ([[operation identifier] isEqualToString:@"Synchronise"] && [operation isExecuting]) {
            DNDebugLog(@"Operation started at: %@", [operation timeStarted]);
            //Compare time:
            if ((![operation isFinished] && ![operation isExecuting]) || ([[operation timeStarted] timeIntervalSinceDate:[NSDate date]] * -1 > 60)) {
                DNDebugLog(@"Operation (%@) cancelled at: %@", operation, [operation timeStarted]);
                [operation cancel];
            }
            else {
                isSyncRunning = YES;
            }
        }
    }];
        
    if (isSyncRunning) {
        if (failure) {
            failure(nil, [DNErrorController errorWithCode:DNCoreSDKErrorDuplicateSynchronise]);
        }
        return isSyncRunning;
    }
    
    DNNetworkOperation *operation = [[DNNetworkOperation alloc] initWithSyncParams:params successBlock:[success copy] failureBlock:[failure copy]];
    [operation setIdentifier:@"Synchronise"];
    [self addOperation:operation];
    
    return isSyncRunning;
}

- (void)sendData:(NSDictionary *)params completion:(DNSignalRCompletionBlock) completion {
    DNNetworkOperation *operation = [[DNNetworkOperation alloc] initWithDataSend:params completion:completion];
    [operation setIdentifier:@"SendData"];
    [self addOperation:operation];
}

@end
