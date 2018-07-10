//
//  DSRMainController.h
//  SignalR
//
//  Created by Donky Networks on 06/08/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Donky_Core_SDK/DNBlockDefinitions.h>
#import <SignalR_ObjC/SRConnection.h>
#import <SignalR_ObjC/SRHubConnection.h>
#import <SignalR_ObjC/SRHubProxy.h>

@interface DSRMainController : NSObject <SRConnectionDelegate>

/*!
 Shared instance of the SignalR connection controller.
 
 @return the shared instance
 
 @since 2.5.4.3
 */
+ (DSRMainController *)sharedInstance;

/*!
 Method to start and open a SignalR connection.
 
 @since 2.5.4.3
 */
- (void)start;

/*!
 Method to close and destory the SignalR connection.
 
 @since 2.5.4.3
 */
- (void)stop;

/*!
 Fully terminate and unregister signalR, this will stop the Core components from being able to
 auto start/stop SignalR on app closes. You will need to call start again to recover.
 
 @since 2.5.4.3
 */
- (void)terminate;

/*!
 Method to determine if the SignalR connection is open and ready.
 
 @return BOOL representing the readiness of the SignalR connection.
 
 @since 2.5.4.3
 */
- (BOOL)signalRIsReady;

#pragma mark -
#pragma mark - Private... Not for public consumption. Public use is unsupported and may result in undesired SDK behaviour.

/*!
 PRIVATE - Please do not use. Use of this API is unsupported and may result in undesired SDK behaviour
 
 @warning Private, please do not use
 */
- (void)sendData:(id)data completion:(DNSignalRCompletionBlock)completionBlock;

@end
