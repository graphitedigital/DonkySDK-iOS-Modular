//
//  DSSequenceController.h
//  DonkySequencing
//
//  Created by Chris Watson on 10/08/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import "DNAccountController.h"

@interface DSSequenceController : NSOperationQueue

+ (DSSequenceController *)sharedInstance;

- (void)updateAdditionalProperties:(NSDictionary *)newAdditionalProperties success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

- (void)saveUserTags:(NSMutableArray *)tags success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

- (void)updateUserDetails:(DNUserDetails *)userDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

- (void)updateRegistrationDetails:(DNUserDetails *)userDetails deviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

- (void)updateDeviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

@end
