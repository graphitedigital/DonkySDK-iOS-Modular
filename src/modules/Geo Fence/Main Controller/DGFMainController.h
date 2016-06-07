//
//  DGFMainController.h
//  GeoFenceModule
//
//  Created by Chris Watson on 19/05/2015.
//  Copyright (c) 2015 Chris Watson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "DNRegion.h"
#import "DGFRegionManager.h"
#import "DGFTriggerManager.h"
#import "DGFLocationHandler.h"
#import "DGFDwellTimer.h"

@class DNSubscription;

/*!
 The controller that peforms all the logic necessary for geo fenciing. This should 
 be started and then can be left to work.
 
 @since 2.6.6.5
 */
@interface DGFMainController : NSObject

/*!
 The location that is currently being processed.
 
 @since 2.6.6.5
 */
@property(nonatomic, strong) CLLocation *currentProcessedLocation;

/*!
 The regions that are stored in memory, these are used to intelligently determine which are the X closest
 to the current user.
 
 @since 2.6.6.5
 */
@property(nonatomic, strong) NSMutableArray *regionsInMemory;

@property(nonatomic, strong) DNSubscription *triggerCreatedSubscription;

@property(nonatomic, strong) DNSubscription *triggerDeletedSubscription;

@property(nonatomic, strong) DNSubscription *regionCreatedSubscription;

@property(nonatomic, strong) DNSubscription *regionDeletedSubscription;

/*!
 The shared singleton for the mananger.
 
 @return a new DGFMainController singleton instance.
 
 @since 2.6.6.5
 */
+ (DGFMainController *)sharedInstance;

/*!
 Method to start the Geo Fence monitoring and associated behaviour.
 
 @since 2.6.6.5
 */
- (void)start;

/*!
 Method to stop the Geo Fence monitoring and all associated behaviour.
 
 @since 2.6.6.5
 */
- (void)stop;

/*!
 Helper method to retrieve all geo fence regions that are currently being monitored.
 
 @return an array containing all the geo fences.
 
 @since 2.6.6.5
 */
- (NSArray *)allGeoFences;

/*!
 Method to retrieve all the geofences with a supplied ID.
 
 @param geoFenceID The id for the geo fence that is requested.
 
 @return an array containing all the geo fences that match the ID.
 
 @since 2.6.6.5
 */
- (NSArray *)allGeoFencesForGeoFenceID:(NSString*)geoFenceID;

/*!
 Method to retrieve all the Geofences with a the supplied name.
 
 @param geoFenceName the name of the geo fence that is wanted.
 
 @return an array containing all those that match the name.
 
 @since 2.6.6.5
 */
- (NSArray *)allGeoFencesForGeoFenceName:(NSString*)geoFenceName;

/*!
 Method to retrieve all triggers for a geofence given the geofence ID.
 
 @param geoFenceID the geofence ID that has the triggers required.
 
 @return an array containing all the triggers.
 
 @since 2.6.6.5
 */
- (NSArray *)allTriggersForGeoFenceID:(NSString*)geoFenceID;

/*!
 Method to retrieve all the triggers for a geofence given the name
 
 @param geoFenceName the name of the geo fence.
 
 @return an array containing all the triggers for the geo fence.
 
 @since 2.6.6.5
 */
- (NSArray *)allTriggersForGeoFenceName:(NSString*)geoFenceName;

/*!
 Method to register for updates to the geo fence database.
 
 @param block call back invoked when there is an update.
 
 @since 2.6.6.5
 */
- (void)registerGeoFenceUpdate:(DGFGeoFenceUpdateBlock)block;

/*!
 Method to unregister a block from receiving geo fence updates.
 
 @param block call back that should be unregistered.
 
 @since 2.6.6.5
 */
- (void)unregisterGeoFenceUpdate:(DGFGeoFenceUpdateBlock)block;

/*!
 Method to register for trigger update notifications.
 
 @param block call back invoked.
 
 @since 2.6.6.5
 */
- (void)registerTriggerUpdate:(DGFTriggerUpdateBlock)block;

/*!
 Method to unregister from trigger update notifications.
 
 @param block call back to un register.
 
 @since 2.6.6.5
 */
- (void)unregisterTriggerUpdate:(DGFTriggerUpdateBlock)block;

/*!
 Method to register for Geo fence crossing events.
 
 @param block call back invoked when a geo fence is crossed.
 
 @since 2.6.6.5
 */
- (void)registerForGeoFenceCrossing:(DGFGeoFenceCrossingUpdateBlock)block;

/*!
 Method to un-register for geo fence crossing events.
 
 @param block call back to un register.
 
 @since 2.6.6.5
 */
- (void)unregisterForGeoFenceCrossing:(DGFGeoFenceCrossingUpdateBlock)block;

/*!
 Method to register for a trigger fired notification.
 
 @param block call back invoked when a trigger is fired.
 
 @since 2.6.6.5
 */
- (void)registerForTriggerFired:(DGFTriggerFiredUpdateBlock)block;

/*!
 Mehtod to un register from triggers fired.
 
 @param block call back to un register.
 
 @since 2.6.6.5
 */
- (void)unregisterForTriggerFired:(DGFTriggerFiredUpdateBlock)block;


#pragma mark - Simulate GeoFence ENTRY / EXIT

/*!
 Method to simulate a update to the currentProcessedLocation.
 
 @param CLLocationCoordinate2D for the location update
 
 @since 2.6.6.5
 */
- (void)simulateLocationUpdateAt:(CLLocationCoordinate2D)location2D;

/*!
 Method to simulate the entry of a Geofence (by name).
 
 @param NSString containing Geofence name for simulated entry
 
 @since 2.6.6.5
 */
- (void)simulateGeoFenceEntryWithName:(NSString*)geoFenceName;

/*!
 Method to simulate the exit of a Geofence (by name).
 
 @param NSString containing Geofence name for simulated exit
 
 @since 2.6.6.5
 */
- (void)simulateGeoFenceExitWithName:(NSString*)geoFenceName;

/*!
 Method to simulate the entry of a Geofence (by ID).
 
 @param NSString containing Geofence ID for simulated entry
 
 @since 2.6.6.5
 */
- (void)simulateGeoFenceEntryWithID:(NSString*)geoFenceID;

/*!
 Method to simulate the exit of a Geofence (by ID).
 
 @param NSString containing Geofence ID for simulated exit
 
 @since 2.6.6.5
 */
- (void)simulateGeoFenceExitWithID:(NSString*)geoFenceID;

#pragma mark -
#pragma mark - Private... Not for public consumption. Public use is unsupported and may result in undesired SDK behaviour.

/*!
 PRIVATE - Please do not use. Use of this API is unsupported and may result in undesired SDK behaviour
 
 @warning Private, please do not use
 */
- (void)newRegistration:(NSDictionary*)data;

/*!
 PRIVATE - Please do not use. Use of this API is unsupported and may result in undesired SDK behaviour
 
 @warning Private, please do not use
 */
- (void)fenceCrossingForRegionID:(NSString*)regionID
                     inDirection:(DGFTriggerRegionDirection)direction
                    timeInRegion:(NSTimeInterval)timeInRegion;

/*!
 PRIVATE - Please do not use. Use of this API is unsupported and may result in undesired SDK behaviour
 
 @warning Private, please do not use
 */
- (void)startTrackingGeoFences;

/*!
 PRIVATE - Please do not use. Use of this API is unsupported and may result in undesired SDK behaviour
 
 @warning Private, please do not use
 */
- (void)stopTrackingGeoFences;

@end
