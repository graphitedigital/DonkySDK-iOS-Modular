//
//  DLSMainController.h
//  Location Services Module
//
//  Created by Donky Networks on 22/10/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "DLSConstants.h"
#import <Donky_Core_SDK/DNModuleDefinition.h>
#import <Donky_Core_SDK/DNSubscription.h>
#import "DLSTargetUser.h"
#import <Donky_Core_SDK/DNBlockDefinitions.h>

/*!
 DLSMainController is responsible for all activities concerning device location measurement. Use this class to obtain and monitor for location updates via the location manager (CLLocationManager). This class also allows you to start and stop the measurement of location by the location manager.
 
 @see CLLocationManager
 @see CLLocation

 @since 2.6.5.4
 */

@interface DLSMainController : NSObject <CLLocationManagerDelegate>

/*!
 The time interval in which the location services should fire the kDLSLocationManagerDidFireLastKnownLocationTimer
 notification.
 
 @since 2.6.6.5
 */
@property (nonatomic) NSTimeInterval reportLocationTimeInterval;

/*!
 The chosen distance filter for the location services.
 
 @since 2.6.6.5
 */
@property (nonatomic) CLLocationDistance implementorDefinedDistanceFilter;

/*!
 BOOL to determine if the location service module should automatically respond to 3rd party location 
 requests. Defualt is NO.
 
 @since 2.6.6.5
 */
@property (nonatomic, getter=shouldAutoRespondToLocationRequests) BOOL autoRespondToLocationRequests;

/*!
 The minimum time interval in which the location services module should send
 the devices location to the network.
 
 @since 2.6.6.5
 */
@property (nonatomic) NSTimeInterval locationUpdateIntervalSeconds;

/*!
 The shared instance for the MainController.
 
 @return the shared instance for the MainController (DLSMainController).
 
 @since 2.6.5.4
 */
+ (DLSMainController *)sharedInstance;

/*!
 The Location Services manager
 
 @return Location Services manager (CLLocationManager)
 
 @since 2.6.5.4
 */
+ (CLLocationManager *)locationServicesManager;

/*!
 Method to start the location tracking services, this includes the following:
    - Sending the device location to the network when the app is loaded/at the minimum time interval.
    - Consuming requests for current location from 3rd parties.
    - Broadcasting an event when a location request has been answered.
 
 @since 2.6.6.5
 */
- (void)startLocationTrackingServices;

/*!
 Method to stop the services related to location tracking, see -startLocationTrackingServices.
 
 @since 2.6.6.5
 */
- (void)stopLocationTrackingServices;

/*!
 Class method to request the location of another user, supplying a 'target' user as the recipient.
 
 @param targetUser the user whose location is required.
 @param deviceId   the specific device's location required, in the case where a user has 
 more than one device registered, this is optional.
 
 @since 2.6.6.5
 */
+ (void)requestUserLocation:(DLSTargetUser *)targetUser targetDeviceID:(NSString *)deviceId;

/*!
 Class method to send the devices location to another app user.
 
 @param targetUser the user to whom you wish to send the devices location, leave nil and the location is 
 recorded on the network.
 @param completion block that is called when the location has been acquired and the notification queued.
 
 @since 2.6.6.5
 */
+ (void)sendLocationUpdateToUser:(DLSTargetUser *)targetUser completionBlock:(DNCompletionBlock)completion;

/*!
 The Last known measured location for the Device. If the location has not yet been measured e.g. if the location updates have not been started, this will be returned as nil.
 
 @return Last Known Location (CLLocation)
 
 @since 2.6.5.4
 */
- (void)requestSingleUserLocation:(DLSLocationUpdateBlock)completion;

/*!
 Method to request the location manager to start measuring and delivering location updates for WhenInUse.
 
 Requesting Permission to Use Location Services :
 The use of location services requires user authorization. Prior to using location services, your app must request authorization from the user to use those services and it must check the availability of the target services. This method attempts to start the location manager assuming you have set the NSLocationWhenInUseUsageDescription key in your app’s Info.plist file. (see Apple iOS documentation CLLocationManager for further informtion.
 
 @since 2.6.5.4
 */
- (void)startWhenInUse;

/*!
 Method to request the location manager to start measuring and delivering location updates for AlwaysUsage.
 
 Requesting Permission to Use Location Services :
 The use of location services requires user authorization. Prior to using location services, your app must request authorization from the user to use those services and it must check the availability of the target services. This method attempts to start the location manager assuming you have set the NSLocationAlwaysUsageDescription key in your app’s Info.plist file. (see Apple iOS documentation CLLocationManager for further informtion.

 @since 2.6.5.4
 */
- (void)startAlwaysUsage;

/*!
 Method to request that the location manager start measuring and delivering location updates. This method defaults to startAlwaysUsage.
 
 @since 2.6.5.4
 */
- (void)startLocationUpdates;

/*!
 Method to request that the location manager stop measuring and delivering location updates.
 
 @since 2.6.5.4
 */
- (void)stopLocationUpdates;

@end
