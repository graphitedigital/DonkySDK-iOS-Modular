//
//  DNSessionManager.h
//  NAAS Core SDK Container
//
//  Created by Chris Watson on 02/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "DNBlockDefinitions.h"

/*!
 The session managed used to create and perform the asynchronous calls to the Donky Network.
 
 @since 2.0.0.0
 */
@interface DNSessionManager : AFHTTPSessionManager

/*!
 Is the current Session Manager using the secure API's.
 
 @since 2.0.0.0
 */
@property (nonatomic, getter=isUsingSecure, readonly) BOOL usingSecure;

/*!
 Initialiser to create a new DNSessionManager.
 
 @param secure BOOL to determine whether this new DNSessionManager should use the secure API route. Secure API is required for all network calls except: Authentication & Registration.
 
 @return a new DNSessionManager object.
 
 @since 2.0.0.0
 */
- (instancetype)initWithSecureURl:(BOOL)secure;

/*!
 Method to perform a POST network call with the specified details.
 
 @param route        the API route to take.
 @param parameters   the data to send to the network.
 @param successBlock block called upon successful completion of the network call.
 @param failureBlock block called upon failure to complete the network call.
 
 @return a new NSURLSessionDataTask object.
 
 @since 2.0.0.0
 */
- (NSURLSessionDataTask *)performPostWithRoute:(NSString *)route parameteres:(NSDictionary *)parameters success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

/*!
 Method to perform a PUT network call with the specified details.
 
 @param route        the API route to take.
 @param parameters   the data to send to the network.
 @param successBlock block called upon successful completion of the network call.
 @param failureBlock block called upon failure to complete the network call.
 
 @return a new NSURLSessionDataTask object.
 
 @since 2.0.0.0
 */
- (NSURLSessionDataTask *)performPutWithRoute:(NSString *)route parameteres:(NSDictionary *)parameters success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

/*!
 Method to perform a DELETE network call with the specified details. 
 
 @param route        the API route to take.
 @param parameters   the data to send to the network.
 @param successBlock block called upon successful completion of the network call.
 @param failureBlock block called upon failure to complete the network call.
 
 @return a new NSURLSessionDataTask object.
 
 @since 2.0.0.0
 */
- (NSURLSessionDataTask *)performDeleteWithRoute:(NSString *)route parameteres:(NSDictionary *)parameters success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

/*!
 Method to perform a GET network call with the specified details.
 
 @param route        the API route to take.
 @param parameters   the data to send to the network.
 @param successBlock block called upon successful completion of the network call.
 @param failureBlock block called upon failure to complete the network call.
 
 @return a new NSURLSessionDataTask object.
 
 @since 2.0.0.0
 */
- (NSURLSessionDataTask *)performGetWithRoute:(NSString *)route parameteres:(NSDictionary *)parameters success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;


@end
