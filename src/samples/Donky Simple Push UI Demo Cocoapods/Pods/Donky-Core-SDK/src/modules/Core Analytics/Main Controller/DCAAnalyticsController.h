//
//  DCAAnalyticsController.h
//  DonkyCoreAnalytics
//
//  Created by Donky Networks on 01/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNLocalEvent.h"

// (PAP) (TODO) Update all the comments in here
/*!
 The controller for reporting various analytics back to Donky Network.
 
 @since 2.0.0.0
 */
@interface DCAAnalyticsController : NSObject

/*!
 The shared instance.
 
 @return the shared instance.
 
 @since 2.0.0.0
 */
+ (DCAAnalyticsController *)sharedInstance;

/*!
 Method to start the analytics.
 
 @since 2.0.0.0
 */
- (void)start;

/*!
 Method to stop the analytics.
 
 @since 2.0.0.0
 */
- (void)stop;

/*!
 Record an app open.
 
 @since 2.0.0.0
 */
- (void)recordInfluencedAppOpen:(BOOL)influenced;

/*!
 Record and app close.
 
 @since 2.0.0.0
 */
- (void)recordAppClose;

/*!
 Record and the Crossing of a GeoFence.

 (PAP) (TOOD) Fix
 @since ?.?.?.?
 */
+ (void)recordGeoFenceCrossing:(NSDictionary *)data;

/*!
 Record and the Triggering of a GeoFence.
 
 (PAP) (TOOD) Fix
 @since ?.?.?.?
 
 (PAP) Example @see DGFModule
 */
+ (void)recordGeoFenceTriggerExecuted:(NSDictionary *)data;

@end
