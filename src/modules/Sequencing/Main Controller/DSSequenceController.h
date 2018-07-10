//
//  DSSequenceController.h
//  DonkySequencing
//
//  Created by Donky Networks on 10/08/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import <Donky_Core_SDK/DNAccountController.h>

@interface DSSequenceController : NSOperationQueue

+ (DSSequenceController *)sharedInstance;

- (void)updateAdditionalProperties:(NSDictionary *)newAdditionalProperties success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

- (void)saveUserTags:(NSMutableArray *)tags success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

- (void)updateUserDetails:(DNUserDetails *)userDetails automaticallyHandleUserIDTaken:(BOOL)autoHandleIDTaken success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock) failureBlock;

- (void)updateRegistrationDetails:(DNUserDetails *)userDetails deviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

- (void)updateDeviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

@end
