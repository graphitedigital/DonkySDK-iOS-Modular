//
//  DSOperation.h
//  DonkySequencing
//
//  Created by Donky Networks on 11/08/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNBlockDefinitions.h"
#import "DNUserDetails.h"
#import "DNDeviceDetails.h"

@interface DSOperation : NSOperation

- (instancetype)initWithNewProperties:(NSDictionary *)newAdditionalProperties success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

- (instancetype)initWithTags:(NSMutableArray *)tags success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

- (instancetype)initWithUserDetails:(DNUserDetails *)userDetails autoHandleUserIDTaken:(BOOL)autoHandle failure:(DNNetworkFailureBlock)failureBlock success:(DNNetworkSuccessBlock)successBlock;

- (instancetype)initWithDeviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

- (instancetype)initWithRegistrationDetails:(DNUserDetails *)userDetails deviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

@end
