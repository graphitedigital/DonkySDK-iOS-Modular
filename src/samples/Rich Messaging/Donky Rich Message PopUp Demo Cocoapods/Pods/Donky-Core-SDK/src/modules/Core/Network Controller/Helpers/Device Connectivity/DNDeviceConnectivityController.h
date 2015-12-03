//
//  DNDeviceConnectivityController.h
//  Core Container
//
//  Created by Chris Watson on 17/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNRequest.h"

/*!
 Helper class to monitor and report on device connectivity state changes. kDNDonkyEventNetworkStateChanged events are published when the devices connectivity state changes i.e. going from WiFI to Cellular. At this point a syncronise call will be made to check for a valid internet connection. The result of which is stored in the validConnection BOOL.
 
 @since 2.0.0.0
 */
@interface DNDeviceConnectivityController : NSObject

/*!
 Bool property for a valid connection.
 
 @since 2.0.0.0
 */
@property(nonatomic, readonly, getter=hasValidConnection) BOOL validConnection;

#pragma mark -
#pragma mark - Private... Not for public consumption. Public use is unsupported and may result in undesired SDK behaviour.

/*!
  PRIVATE - Please do not use. Use of this API is unsupported and may result in undesired SDK behaviour
 */
- (void)addFailedRequestToQueue:(DNRequest *)request;

@end
