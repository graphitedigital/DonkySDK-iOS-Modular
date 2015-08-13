//
//  DSOperation.h
//  DonkySequencing
//
//  Created by Chris Watson on 11/08/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNBlockDefinitions.h"
#import "DNUserDetails.h"
#import "DNDeviceDetails.h"

@interface DSOperation : NSOperation

- (instancetype)initWithNewProperties:(NSDictionary *)newAdditionalProperties success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

- (instancetype)initWithTags:(NSMutableArray *)tags success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

- (instancetype)initWithUserDetails:(DNUserDetails *)userDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

- (instancetype)initWithDeviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

- (instancetype)initWithRegistrationDetails:(DNUserDetails *)userDetails deviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

@end
