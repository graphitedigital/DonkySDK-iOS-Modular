//
//  DSOperation.m
//  DonkySequencing
//
//  Created by Donky Networks on 11/08/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DSOperation.h"
#import <Donky_Core_SDK/DNAccountController.h>

typedef enum {
    DSAdditionalProperties = 0,
    DSTags,
    DSUserDetails,
    DSRegistrationDetails,
    DSDeviceDetails
} DSSequenceCalls;

@interface DSOperation ()
@property (nonatomic, strong) NSDictionary *additionalProperties;
@property (nonatomic, copy) DNNetworkSuccessBlock successBlock;
@property (nonatomic, copy) DNNetworkFailureBlock failureBlock;
@property (nonatomic, getter=shouldAutoHandle) BOOL autoHandle;
@property (nonatomic, strong) DNDeviceDetails *deviceDetails;
@property (nonatomic, strong) DNUserDetails *userDetails;
@property (nonatomic, strong) NSMutableArray *tags;
@property (nonatomic) DSSequenceCalls callType;
@end

@implementation DSOperation

#pragma Configure basic operation

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setFinished:NO];
        [self setExecuting:NO];
    }
    return self;
}

- (instancetype)initWithNewProperties:(NSDictionary *)newAdditionalProperties success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
 
    self = [self init];
    
    if (self) {
        [self setAdditionalProperties:newAdditionalProperties];
        [self setSuccessBlock:successBlock];
        [self setFailureBlock:failureBlock];

        [self setCallType:DSAdditionalProperties];
    }

    return self;
}

- (instancetype)initWithTags:(NSMutableArray *)tags success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    self = [self init];

    if (self) {
        [self setTags:tags];
        [self setSuccessBlock:successBlock];
        [self setFailureBlock:failureBlock];

        [self setCallType:DSTags];
    }

    return self;
}

- (instancetype)initWithUserDetails:(DNUserDetails *)userDetails autoHandleUserIDTaken:(BOOL)autoHandle failure:(DNNetworkFailureBlock)failureBlock success:(DNNetworkSuccessBlock)successBlock {
    self = [self init];
    
    if (self) {
        [self setAutoHandle:autoHandle];
        [self setUserDetails:userDetails];
        [self setSuccessBlock:successBlock];
        [self setFailureBlock:failureBlock];

        [self setCallType:DSUserDetails];
    }

    return self;
}

- (instancetype)initWithDeviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
   
    self = [self init];

    if (self) {
        [self setDeviceDetails:deviceDetails];
        [self setSuccessBlock:successBlock];
        [self setFailureBlock:failureBlock];

        [self setCallType:DSDeviceDetails];
    }

    return self;
}

- (instancetype)initWithRegistrationDetails:(DNUserDetails *)userDetails deviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {

    self = [self init];

    if (self) {
        [self setDeviceDetails:deviceDetails];
        [self setUserDetails:userDetails];
        [self setSuccessBlock:successBlock];
        [self setFailureBlock:failureBlock];

        [self setCallType:DSDeviceDetails];
    }

    return self;
}

- (void)start {
    if ([self isCancelled]) {
        [self setFinished:YES];
        return;
    }

    [self setExecuting:YES];

    [self main];
}

- (void)completeOperation {
    [self setExecuting:NO];
    [self setFinished:YES];
}

- (void)main
{
    switch ([self callType]) {
        case DSAdditionalProperties: {
            [DNAccountController updateAdditionalProperties:[self additionalProperties] success:^(NSURLSessionDataTask *task, id responseData) {
                [self executeCompletion:task responseData:responseData];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [self executeFailure:task error:error];
            }];
        }
            break;
        case DSTags: {
            [DNAccountController saveUserTags:[self tags] success:^(NSURLSessionDataTask *task, id responseData) {
                [self executeCompletion:task responseData:responseData];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [self executeFailure:task error:error];
            }];
        }
            break;
        case DSUserDetails: {
            [DNAccountController updateUserDetails:[self userDetails] automaticallyHandleUserIDTaken:[self shouldAutoHandle] success:^(NSURLSessionDataTask *task, id responseData) {
                [self executeCompletion:task responseData:responseData];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [self executeFailure:task error:error];
            }];
        }
            break;
        case DSRegistrationDetails: {
            [DNAccountController updateRegistrationDetails:[self userDetails] deviceDetails:[self deviceDetails] success:^(NSURLSessionDataTask *task, id responseData) {
                [self executeCompletion:task responseData:responseData];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [self executeFailure:task error:error];
            }];
        }
            break;
        case DSDeviceDetails: {
            [DNAccountController updateDeviceDetails:[self deviceDetails] success:^(NSURLSessionDataTask *task, id responseData) {
                [self executeCompletion:task responseData:responseData];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [self executeFailure:task error:error];
            }];
        }
            break;
    }
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
    if ([self isExecuting] != executing) {
        [self setExecuting:executing];
    }
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)setFinished:(BOOL)finished
{
    [self willChangeValueForKey:@"isFinished"];
    if ([self isFinished] != finished) {
        [self setFinished:finished];
    }
    [self didChangeValueForKey:@"isFinished"];
}

@end
