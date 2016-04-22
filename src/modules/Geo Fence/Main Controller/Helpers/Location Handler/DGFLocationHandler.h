//
//  DGFLocationHandler.h
//  GeoFenceModule
//
//  Created by Donky Networks on 30/10/2015.
//  Copyright © 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "DGFConstants.h"

@interface DGFLocationHandler : NSObject

@property(nonatomic) CLLocationCoordinate2D controlRegionCentreCoordinate;
@property(nonatomic) CLLocationDistance controlRegionRadius;
@property(nonatomic, strong) NSTimer *isMovingTimer;

+ (DGFLocationHandler *)sharedInstance;

- (void)updateLocation:(CLLocation*)locationUpdate fromLocationManager:(CLLocationManager*)locationManager;
- (void)sortGeofencesInMemoryFromCurrentLocation;
- (void)updateWithUserSelectedLocation:(CLLocationCoordinate2D)userLocationCoordinate;
- (void)addGeoFenceForControlRegion;

@end
