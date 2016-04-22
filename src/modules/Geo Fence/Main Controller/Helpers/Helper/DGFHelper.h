//
//  DGFHelper.h
//  GeoFenceModule
//
//  Created by Donky Networks on 29/10/2015.
//  Copyright © 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface DGFHelper : NSObject

+ (CLLocationDistance)calculateDistanceToCentre:(NSDictionary*)centrePointDict fromLocation:(CLLocationCoordinate2D)location;

@end
