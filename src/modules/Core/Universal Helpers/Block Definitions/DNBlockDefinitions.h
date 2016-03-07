//
//  DKBlockDefinitions.h
//  NAAS Core SDK Container
//
//  Created by Donky Networks on 18/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNLocalEvent.h"
#import "DNAuthResponse.h"
#import "DNAuthenticationObject.h"

/*!
 Success block definition used for all methods that perform a network call.
 
 @param task         the network task created for this operation.
 @param responseData the data sent back from the operation.
 
 @since 2.0.0.0
 */
typedef void (^DNNetworkSuccessBlock) (NSURLSessionDataTask *task, id responseData);

/*!
  Failure block used for all methods that perform a network call.
 
 @param task         the network task created for this operation.
 @param error        the NSError object containing the failure details.
 
 @since 2.0.0.0
 */
typedef void (^DNNetworkFailureBlock) (NSURLSessionDataTask *task, NSError *error);

/*!
 The block definition used for Local events.
 
 @since 2.0.0.0
 */
typedef void (^DNLocalEventHandler) (DNLocalEvent * event);

/*!
 The completion block used for when signalR has completed processing data.
 
 @param response the response from the network or the data sent from the network.
 @param error    any error passed from the network.
 
 @since 2.6.5.4
 */
typedef void (^DNSignalRCompletionBlock) (id response, NSError *error);

/*!
 The completion block for when an asset has been successfully uploaded.
 
 @param asset the returned data about the asset.
 
 @since 2.6.5.5
 */
typedef void (^DAAssetUploadSuccessBlock) (id asset);

/*!
 The completion block used when an asset upload fails.
 
 @param error the error as to why the upload failed.
 
 @since 2.6.5.5
 */
typedef void (^DAAssetUploadFailureBlock) (NSError *error);

/*!
 The completion block used in the network controller.
 
 @param data the data returned.
 
 @since 2.6.5.5
 */
typedef void (^DNNetworkControllerSuccessBlock) (id data);

/*!
 A generic completion block used across the SDK. Please check the method comments for the
 data return type.
 
 @param data generic, changeable data type returned, can be nil.
 
 @since 2.6.5.5.
 */
typedef void (^DNCompletionBlock) (id data);

/*!
 Block used by the SDK to return the required details back to inegrators so that an auth token can be generated and returned to the SDK.
 
 @param authDetails     the auth details returned by the network. Use this to generate your token.
 @param expectedDetails can be nil, this will contain the userID and/or nonce for the user which the SDK expects the token to relate to. Use this to determine if a new user has started using the app, in this case, a re-registration may be required.
 @param error           any errors returned by the SDK. Check for a nil error object before attempting to generate a token.
 
 @since 2.7.1.3
 */
typedef void (^DNAuthenticationRequestCompletion) (DNAuthResponse *authDetails, DNAuthenticationObject *expectedDetails, NSError *error);

/*!
 Block used to return the token and auth details back to the SDK, this block is provided by the DonkyCore authentication handler and integrators are required
 to invoke this block and provide the required information so that the SDK can re-authenticate when the token needs to be refreshed.
 
 @param token       the token to be used to authenticate against the current user.
 @param authDetails the authentication details used to generate the token, this is provided by the SDK.
 
 @since 2.7.1.3
 */
typedef void (^DNAuthenticationCompletion) (NSString *token, DNAuthResponse *authDetails);

/*!
 Block used by the SDK internally, which integrators should define, so that the SDK can asynchronously refresh it's authentication token as and when required. @see DNDonkyCore for where
 this property should be set.
 
 @param completionBlock the completion block that should be invoked by the integrators after a token has been generated.
 @param authDetails     the auth details that should be used to generate the token.
 @param expectedDetails can be nil, this will contain the userID and/or nonce for the user which the SDK expects the token to relate to. Use this to determine if a new user has started using the app, in this case, a re-registration may be required.
 
 @since 2.7.1.3
 */
typedef void (^DNAuthenticationHandler) (DNAuthenticationCompletion completionBlock, DNAuthResponse *authDetails, DNAuthenticationObject *expectedDetails);

