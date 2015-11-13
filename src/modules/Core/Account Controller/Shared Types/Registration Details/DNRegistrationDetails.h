//
//  DNRegistrationDetails.h
//  Core Container
//
//  Created by Donky Networks on 17/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DNDeviceDetails.h"
#import "DNClientDetails.h"
#import "DNUserDetails.h"

/*!
 All of the registration details stored about the current user, device and client SDK. NOTE: When changing any of the
 details about the registered user, it is important to call [DNAccountController updateRegistrationDetails: deviceDetails:success:failure:].
 Or, if only updating one detail then call the appropriate update method in DNAccountController.
 
 @since 2.0.0.0
 */
@interface DNRegistrationDetails : NSObject

/*!
 The user details stored on the network for the currently registered device user.
 
 @see DNUserDetails
 
 @since 2.0.0.0
 */
@property(nonatomic, readonly) DNUserDetails *userDetails;

/*!
 All of the device details stored about the current device on the network.
 
 @see DNDeviceDetails
 
 @since 2.0.0.0
 */
@property(nonatomic, readonly) DNDeviceDetails *deviceDetails;

/*!
 The details of the client SDK. See DNClientDetails for readwrite properties.
 
 @see DNClientDetails
 
 @since 2.0.0.0
 */
@property(nonatomic, readonly) DNClientDetails *clientDetails;

/*!
 Initialiser to create a new instance of DNRegistrationDetails with the provided device, client or user details.
 
 @param deviceDetails details of the current device.
 @param clientDetails details of the current client.
 @param userDetails   details of the current user.
 
 @see DNDeviceDetails
 @see DNUserDetails
 
 @return a new DNRegistrationDetails object.
 
 @since 2.0.0.0
 */
- (instancetype) initWithDeviceDetails:(DNDeviceDetails *)deviceDetails clientDetails:(DNClientDetails *)clientDetails userDetails:(DNUserDetails *)userDetails;

@end
