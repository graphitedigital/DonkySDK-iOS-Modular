//
//  DNAuthResponse.h
//  DonkyMaster
//
//  Created by Chris Watson on 18/02/2016.
//  Copyright © 2016 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DNAuthResponse : NSObject

/*!
 The nonce returned from the Donky Network.
 
 @since 2.7.1.3
 */
@property(nonatomic, readonly) NSString *nonce;

/*!
 The provider of the authentication service.
 
 @since 2.7.1.3
 */
@property(nonatomic, readonly) NSString *provider;

/*!
 BOOL indicating whether the use of a nonce is required.
 
 @since 2.7.1.3
 */
@property(nonatomic, readonly, getter=isNonceRequired) BOOL nonceRequired;

/*!
 The authentication ID of the service.
 
 @since 2.7.1.3
 */
@property(nonatomic, readonly) NSString *authenticationID;

/*!
 Initialiser to create a new instance of the DNAuthReponse object with the data from the network.
 
 @param response the response from the network that contains the relevant properites.
 
 @return a new instance of DNAuthReponse
 
 @since 2.7.1.3
 */
- (instancetype)initWithAuthenticationStartResponse:(NSDictionary *)response;

#pragma mark -
#pragma mark - Private... Not for public consumption. Public use is unsupported and may result in undesired SDK behaviour.

/*!
 PRIVATE - Please do not use. Use of this API is unsupported and may result in undesired SDK behaviour
 
 @warning Private, please do not use.
 */
- (NSDictionary *)parameters;

@end
