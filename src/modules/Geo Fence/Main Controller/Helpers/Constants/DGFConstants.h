//
//  DGFConstants.h
//  GeoFenceModule
//
//  Created by Chris Watson on 13/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark -
#pragma mark - Geo Fence Module shared constants

typedef enum {
    DGFTriggerRegionDirectionBoth,
    DGFTriggerRegionDirectionIn,
    DGFTriggerRegionDirectionOut,
} DGFTriggerRegionDirection;

typedef enum {
    DGFGeoFenceCrossingExit,
    DGFGeoFenceCrossingEntry,
} DGFGeoFenceCrossing;

typedef void (^DGFGeoFenceUpdateBlock) (NSDictionary *geoFenceData);
typedef void (^DGFGeoFenceCrossingUpdateBlock) (DGFGeoFenceCrossing direction, NSString *geoFenceID);
typedef void (^DGFTriggerUpdateBlock) (NSDictionary *triggerData);
typedef void (^DGFTriggerFiredUpdateBlock) (NSDictionary *triggerData);

// (PAP) (TODO) These need TUNING
#define kDGFDefaultDwellTimeIfNotSetSeconds 5
#define kDGFAdditionalMonitoredFences 0
#define kDGFMinimumSizeOfControlRegionMetres 10
#define kDGFMaximumSizeOfControlRegionMetres 1000
#define kDGFNumberOfClosestFencesUsedToDefineControlRegion 10

// This is defined by Apple
#define kDGFLocationManagerMaxNumberOfRegionsThanCanBeMonitored 20

// location manager to ignore accuracy
#define kDGFIgnoreLocationUpdatesOfHorizontalAccuracyGreaterThan 100

// location manager FOREGROUND CONFIGURATION - LIVE
#define kDGFlLocationManager1desiredAccuracy kCLLocationAccuracyNearestTenMeters
#define kDGFLocationManager2activityType CLActivityTypeFitness
#define kDGFLocationManager3minimumDistanceFilter 20
// distance filter based on speed
#define kDGFDistanceFilterConversionFactor 12
#define kDGFNumberOfSpeedMeasurements 4
#define kDGFCheckIfDeviceHasMovedAfterSeconds 60
// NOTE: This must be set to value >= 1 second
#define kDGFIgnoreLocationUpdatesGeneratedLessThanSecondsAgo 1

//location manager BACKGROUND CONFIGURATION - LIVE
//#define kDGFlocationManager1desiredAccuracy kCLLocationAccuracyBest
//#define kDGFLocationManager2activityType CLActivityTypeFitness
//#define kDGFLocationManager3minimumDistanceFilter kCLDistanceFilterNone

// if battery falls below 15% switch off location measurement
#define kDGFEnableAutoPowerSaveOption YES
// minimum battery level is 0.15 = 15%
#define kDGFAutoPowerSaveOptionMinimumBatteryLevel 0.15

//
extern NSString * const kDGFTriggerConfigurationNotification;

//
extern NSString * const kDGFTriggerDeletedNotification;

//
extern NSString * const kDGFStartTrackingLocationNotification;

//
extern NSString * const kDGFStopTrackingLocationNotification;

//
extern NSString * const kDGFidForGeoFenceControlRegion;

//
extern NSString * const kDFSimulateGeoFenceEntry;

//
extern NSString * const kDFSimulateGeoFenceExit;


