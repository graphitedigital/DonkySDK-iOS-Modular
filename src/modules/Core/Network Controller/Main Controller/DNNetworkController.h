//
//  DNNetworkController.h
//  NAAS Core SDK Container
//
//  Created by Donky Networks on 16/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNBlockDefinitions.h"
#import "DNRetryHelper.h"

typedef enum {
    DNPost,
    DNGet,
    DNDelete,
    DNPut,
    DNNone
} DonkyNetworkRoute;

/*!
 DNNetworkController is responsible for handling all traffic to and from the Donky Network. When sending custom content please do so through
 direct access to this controller.
 
 @since 2.0.0.0
 */
@interface DNNetworkController : NSObject

/*!
 The singleton instance.
 
 @return a singleton instance of the controller.
 
 @since 2.0.0.0
 */
+ (DNNetworkController *)sharedInstance;

/*!
 Method used to contact the Donky Network. This passes the network request to the Third Party AFNetworking library which is responsible for queueing, performing and receiving data from the network. This is the method to replace if using  AFNetworking is not possible.
 
 @param secure       if this call should use the secure API, this is only available after a device has been registered.
 @param route        the end point of the Donky Network API. These are all in DKConstants.h.
 @param method       the HTTP Verb to use, PUT/POST etc... These are all in DKConstants.h.
 @param parameters   the data that is to be sent along with the request. In NSDictionary form, the data will be parsed into JSON before being sent.
 @param successBlock block to be called upon a successful request.
 @param failureBlock block to be called upon a failure to perform the specified request.
 
 @since 2.0.0.0
 */
- (void)performSecureDonkyNetworkCall:(BOOL)secure route:(NSString *)route httpMethod:(DonkyNetworkRoute)method parameters:(id)parameters success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

/*!
 Method to perform a streaming upload to the network. While this API is 'public' it should only really be accessed via the Asset Module as this provides
 a contextual wrapper for any assets that you may want to upload.
 
 @param assetsToUpload the asset details that should be uploaded.
 @param successBlock block to be called upon a successful request.
 @param failureBlock block to be called upon a failure to perform the specified request.
 
 @since 2.6.5.5
 */
- (void)streamAssetUpload:(NSArray *)assetsToUpload success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

/*!
 When wishing to send or receive new data from to/from the Donky Network. Manually invoking this method will force a Server Data refresh. All pending client
 types are sent and incoming types are directed to their subscribers. If the completion blocks are not required, simply us synchronise.
 
 @param successBlock block used upon successful completion.
 @param failureBlock lock used to catch any errors from the network.
 
 @since 2.0.0.0
 */
- (void)synchroniseSuccess:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

/*!
 Method to retrieve all the pending server notifications on the network for this device. NOTE: This method will not send any pending DNContentNotifications to the server. To do this, please use synchronise/sendNotification:success:failure:
 
 @param successBlock block to be called upon a successful request.
 @param failureBlock block to be called upon a failure to perform the specified request.
 
 @since 2.0.0.0
 */
- (void)allServerNotificationsSuccess:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

/*!
 Method to perform a full Donky Network synchronisation. This gathers and prepares all DNContentNotifications and sends those to the network. The response will contain all pending server notifications. All received notifications will be sent to DNDonkyCore, processed and delivered to the relevant subscribers.
 
 @since 2.0.0.0
 */
- (void)synchronise;

/*!
 Method to send content notifications to the network immediately. This will not retrieve server notifications. Perform a signalRHubProxy to send and receive.
 
 @param notifications an array containing the content notifications.
 @param successBlock block to be called upon a successful request.
 @param failureBlock block to be called upon a failure to perform the specified request.
 
 @see DNContentNotification
 
 @since 2.0.0.0
 */
- (NSError *)sendContentNotifications:(NSArray *)notifications success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

/*!
 Method to queue content notifications ready to be send to the network. Call this method if the notifications can be sent at the next Syncronise. If the notification must be sent immediately then please use sendNotification:success:failure
 
 @param notifications an array of notifications that should be queued and saved to the data base. They will be sent at the next signalRHubProxy.
 
 @since 2.0.0.0
 */
- (NSError *)queueContentNotifications:(NSArray *)notifications;

/*!
 Method to retrieve a specific pending server notification from the network.
 
 @param notificationID the ID of the server notification that is needed.
 @param successBlock block to be called upon a successful request.
 @param failureBlock block to be called upon a failure to perform the specified request.
 
 @since 2.0.0.0
 */
- (void)serverNotificationForId:(NSString *)notificationID success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

#pragma mark -
#pragma mark - Private... Not for public consumption. Public use of these APIs is unsupported.

/*!
  PRIVATE - Please do not use. Use of this API is unsupported and may result in undesired SDK behaviour
 
  @warning Private, please do not use
 */
- (void)queueClientNotifications:(NSArray *)notifications;

/*!
  PRIVATE - Please do not use. Use of this API is unsupported and may result in undesired SDK behaviour
 
  @warning Private, please do not use
 */
- (void)startMinimumTimeForSynchroniseBuffer:(NSTimeInterval)buffer;

@end
