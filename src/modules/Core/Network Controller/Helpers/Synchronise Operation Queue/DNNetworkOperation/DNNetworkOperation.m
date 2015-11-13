//
//  DNNetworkOperation.m
//  ChatUI
//
//  Created by Donky Networks on 24/09/2015.
//  Copyright © 2015 Donky Networks. All rights reserved.
//

#import "DNNetworkOperation.h"
#import "DNNetworkController.h"
#import "DNConstants.h"
#import "DNSignalRInterface.h"

@interface DNNetworkOperation ()
@property (nonatomic, readwrite, getter = isFinished)  BOOL finished;
@property (nonatomic, readwrite, getter = isExecuting) BOOL executing;
@property (nonatomic, copy) DNNetworkSuccessBlock successBlock;
@property (nonatomic, copy) DNNetworkFailureBlock failureBlock;
@property (nonatomic, copy) DNSignalRCompletionBlock completion;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, readwrite) NSDate *timeStarted;
@end

@implementation DNNetworkOperation

@synthesize finished = _finished, executing = _executing;

- (instancetype)initWithSyncParams:(NSDictionary *)params successBlock:(DNNetworkSuccessBlock)success failureBlock:(DNNetworkFailureBlock)failure {
    
    self = [self init];
    
    if (self) {
    
        [self setParams:params];
        [self setSuccessBlock:success];
        [self setFailureBlock:failure];
        
    }
    
    return self;
}

- (instancetype)initWithDataSend:(NSDictionary *)params completion:(DNSignalRCompletionBlock)completion {
    self = [self init];
    
    if (self) {
        [self setParams:params];
        [self setCompletion:completion];
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setFinished:NO];
        [self setExecuting:NO];
    }
    return self;
}

- (void)start
{
    if ([self isCancelled]) {
        [self setFinished:YES];
        return;
    }
    
    [self setTimeStarted:[NSDate date]];
    
    [self setExecuting:YES];
    
    [self main];
}

- (void)completeOperation
{
    
    [self setExecuting:NO];
    [self setFinished:YES];
}

- (void)main {
    if ([self completion]) {
        [DNSignalRInterface sendData:[self params] completion:^(id response, NSError *error) {
            if ([[NSThread currentThread] isMainThread]) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    [self executeSignalRCompletion:response withError:error];                    
                });
            }
            else {
                [self executeSignalRCompletion:response withError:error];
            }

        }];
    }
    else {
        [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:YES route:kDNNetworkNotificationSynchronise httpMethod:DNPost parameters:[self params] success:^(NSURLSessionDataTask *task, id responseData) {
            [self executeCompletion:task responseData:responseData];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [self executeFailure:task error:error];
        }];
    }
}

- (void)executeSignalRCompletion:(id)response withError:(NSError *) error {
    if ([self completion]) {
        if ([[NSThread currentThread] isMainThread]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [self completion](response, error);
            });
        }
        else {
            [self completion](response, error);
        }
    }
    [self completeOperation];
}

- (void)executeCompletion:(NSURLSessionDataTask *)task responseData:(id)responseData {
    if ([self successBlock]) {
        [self successBlock](task, responseData);
    }
    [self completeOperation];
}


- (void)executeFailure:(NSURLSessionDataTask *)task error:(NSError *)error {
    if ([self failureBlock]) {
        [self failureBlock](task, error);
    }
    [self completeOperation];
}

#pragma mark - Standard NSOperation methods

- (BOOL)isAsynchronous {
    return YES;
}

- (void)setExecuting:(BOOL)executing
{
    [self willChangeValueForKey:@"isExecuting"];
    if (_executing != executing) {
        _executing = executing;
    }
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)setFinished:(BOOL)finished
{
    [self willChangeValueForKey:@"isFinished"];
    if (_finished != finished) {
        _finished = finished;
    }
    [self didChangeValueForKey:@"isFinished"];
}

- (void)cancel {
    [self executeFailure:nil error:nil];
}

@end
