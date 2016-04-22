//
//  DGFDwellTime.h
//  GeoFenceModule
//
//  Created by Donky Networks on 29/10/2015.
//  Copyright © 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DGFMainController.h"

@interface DGFDwellTimer : NSObject

@property(nonatomic) BOOL isTrackingGeoFences;

+ (DGFDwellTimer *)sharedInstance;

- (void)markForDwellTimeCheckAtCurrentLocation;
- (void)markForDwellTimeCheckAtLocation:(CLLocationCoordinate2D)location;

@end
