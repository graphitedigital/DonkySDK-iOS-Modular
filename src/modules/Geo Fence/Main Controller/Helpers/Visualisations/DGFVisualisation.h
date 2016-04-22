//
//  DGFVisualisation.h
//  GeoFenceModule
//
//  Created by Donky Networks on 30/10/2015.
//  Copyright © 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface DGFVisualisation : NSObject

+ (void)trackLocationUpdateOnMapViewForLocation:(CLLocation *)userLocation;

+ (void)addOverlayForRegionUsingDictionary:(NSDictionary*)dictionary;
+ (void)addOverlayForCircle:(MKCircle*)circle;

+ (void)removeAllOverlays;
+ (void)removeOverlayForID:(NSString*)iD;

+ (void)displayGeoFenceEntryForFenceID:(NSString*)fenceID;
+ (void)displayGeoFenceExitForFenceID:(NSString*)fenceID;

+ (void)updateNumberOfFences:(NSInteger)numberOfFences;

@end
