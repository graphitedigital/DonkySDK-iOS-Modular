//
//  DNSignalRInterface.h
//  SignalR
//
//  Created by Donky Networks on 06/08/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNBlockDefinitions.h"

@interface DNSignalRInterface : NSObject

/*!
 Method to open a SignalR connection. If on is already open the nothing will happen.
 
 @since 2.6.5.4
 */
+ (void)openConnection;

/*!
 Method to close a SignalR connection. If one is not open then nothing will happen.
 
 @since 2.6.5.4
 */
+ (void)closeConnection;

/*!
 Helper method to determine if a SignalR connection is open.
 
 @return BOOL representing a connection state for SignalR
 
 @since 2.6.5.4
 */
+ (BOOL)signalRServiceIsReady;

#pragma mark -
#pragma mark - Private... Not for public consumption. Public use is unsupported and may result in undesired SDK behaviour.

/*!
 PRIVATE - Please do not use. Use of this API is unsupported and may result in undesired SDK behaviour
 
 @warning Private, please do not use
 */
+ (void)sendData:(id)data completion:(DNSignalRCompletionBlock)completionBlock;

@end
