//
//  DLSConstants.h
//  Location Services Module
//
//  Created by Donky Networks on 13/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

//
typedef void (^DLSLocationUpdateBlock) (CLLocationManager *manager, CLLocation *userLocation);

//
extern NSString * const kDLSLocationManagerDidChangeAuthorizationStatus;

//
extern NSString * const kDLSLocationManagerDidFailWithError;

//
extern NSString * const kDLSLocationManagerDidUpdateLocations;

//
extern NSString * const kDLSLocationManagerDidFireLastKnownLocationTimer;

//
extern NSString * const kDLSLocationManagerDidUpdateHeading;

//
extern NSString * const kDLSLocationManagerDidPauseLocationUpdates;

//
extern NSString * const kDLSLocationManagerDidResumeLocationUpdates;

//
extern NSString * const kDLSLocationManagerDidStartMonitoringForRegion;

//
extern NSString * const kDLSLocationManagerDidExitRegion;

//
extern NSString * const kDLSLocationManagerDidEnterRegion;

//
extern NSString * const kDLSLocationManagerDidDetermineStateForRegion;

//
extern NSString * const kDLSLocationManagerMonitoringDidFailForRegion;

//
extern NSString * const kDLSLocationRequestNotification;

//
extern NSString * const kDLSLocationUpdateNotification;


