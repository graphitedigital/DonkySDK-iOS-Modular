//
//  DSSequenceController.m
//  DonkySequencing
//
//  Created by Donky Networks on 10/08/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DSSequenceController.h"
#import "DSOperation.h"

@interface DSSequenceController ()
@end

@implementation DSSequenceController

+(DSSequenceController *)sharedInstance
{
    static dispatch_once_t pred;
    static DSSequenceController *sharedInstance = nil;

    dispatch_once(&pred, ^{
        sharedInstance = [[DSSequenceController alloc] initPrivate];
    });
    return sharedInstance;
}

-(instancetype)init {
    return [DSSequenceController sharedInstance];
}

-(instancetype)initPrivate {

    self = [super init];
    
    if (self) {
        [self setName:NSStringFromClass([self class])];
        [self setMaxConcurrentOperationCount:1];
    }

    return self;
}

- (void)updateAdditionalProperties:(NSDictionary *)newAdditionalProperties success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    DSOperation *blockOperation = [[DSOperation alloc] initWithNewProperties:newAdditionalProperties success:successBlock failure:failureBlock];
    [self addOperation:blockOperation];
}

- (void)saveUserTags:(NSMutableArray *)tags success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    DSOperation *blockOperation = [[DSOperation alloc] initWithTags:tags success:successBlock failure:failureBlock];
    [self addOperation:blockOperation];
}

- (void)updateUserDetails:(DNUserDetails *)userDetails automaticallyHandleUserIDTaken:(BOOL)autoHandleIDTaken success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    DSOperation *blockOperation = [[DSOperation alloc] initWithUserDetails:userDetails autoHandleUserIDTaken:autoHandleIDTaken failure:failureBlock success:successBlock];
    [self addOperation:blockOperation];
}

- (void)updateRegistrationDetails:(DNUserDetails *)userDetails deviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    DSOperation *blockOperation = [[DSOperation alloc] initWithRegistrationDetails:userDetails deviceDetails:deviceDetails success:successBlock failure:failureBlock];
    [self addOperation:blockOperation];
}

- (void)updateDeviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    DSOperation *blockOperation = [[DSOperation alloc] initWithDeviceDetails:deviceDetails success:successBlock failure:failureBlock];
    [self addOperation:blockOperation];
}

@end
