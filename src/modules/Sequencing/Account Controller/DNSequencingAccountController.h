//
//  DNSequencingAccountController.h
//  DonkySequencing
//
//  Created by Chris Watson on 10/08/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import "DNAccountController.h"

@interface DNSequencingAccountController : DNAccountController

/*!
 Method to update a users additional properties. NOTE: This is destructive, if you don't pass in all existing properties as well as
 additional ones and changes, you will lose them.

 @param newAdditionalProperties the new complete additional properties to be saved against this user.
 @param successBlock  block called upon successful completion of the operation.
 @param failureBlock  block called upon failure to complete the operation.

 @since 2.5.4.3
 */
+ (void)updateAdditionalProperties:(NSDictionary *)newAdditionalProperties success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

/*!
 This saves the provided tags on the network.

 @param tags         the tags that should be saved against this user on the network.
 @param successBlock  block called upon successful completion of the operation.
 @param failureBlock  block called upon failure to complete the operation.

 @see DNUserDetails

 @since 2.5.4.3
 */
+ (void)saveUserTags:(NSMutableArray *)tags success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

/*!
 Method to update the user that is linked against this account on the network.

 @param userDetails  the user details that should be updated on the network.
 @param successBlock      block called upon successful completion.
 @param failureBlock      block called upon failure to complete the operation.

 @see DNUserDetails

 @since 2.5.4.3
 */
+ (void)updateUserDetails:(DNUserDetails *)userDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

/*!
 Method to update multiple parts of the users and device details at once.

 @param userDetails   the user details to update on the network. Can be nil to create a new anonymous registration.
 @param deviceDetails the device details to update on the network. Can be nil.
 @param successBlock  block called upon successful completion of the network operation.
 @param failureBlock  block called upon failure of the network operation.

 @see DNUserDetails
 @see DNDeviceDetails

 @since 2.5.4.3
 */
+ (void)updateRegistrationDetails:(DNUserDetails *)userDetails deviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

/*!
 Method to update the device details linked against this device on the network. DNDeviceDetails.

 @param deviceDetails the device details with the properties to use when updating the network details. Pass nil to create a 'fresh' device.
 @param successBlock  block called upon successful completion.
 @param failureBlock  block called upon failure to complete the operation.

 @see DNDeviceDetails

  @since 2.5.4.3
 */
+ (void)updateDeviceDetails:(DNDeviceDetails *)deviceDetails success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

@end
