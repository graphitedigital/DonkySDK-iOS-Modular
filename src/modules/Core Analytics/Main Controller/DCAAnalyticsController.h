//
//  DCAAnalyticsController.h
//  DonkyCoreAnalytics
//
//  Created by Chris Watson on 01/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNLocalEvent.h"

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

@end
