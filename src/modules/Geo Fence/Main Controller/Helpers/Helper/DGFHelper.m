//
//  DGFHelper.m
//  GeoFenceModule
//
//  Created by Donky Networks on 29/10/2015.
//  Copyright © 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DGFHelper.h"

@implementation DGFHelper

+ (CLLocationDistance)calculateDistanceToCentre:(NSDictionary*)centrePointDict fromLocation:(CLLocationCoordinate2D)location
{
    CLLocationCoordinate2D centre = CLLocationCoordinate2DMake([centrePointDict[@"latitude"] doubleValue],
                                                               [centrePointDict[@"longitude"] doubleValue]);
    MKMapPoint locationPoint = MKMapPointForCoordinate(location);
    MKMapPoint regionPoint = MKMapPointForCoordinate(centre);
    
    return MKMetersBetweenMapPoints(locationPoint, regionPoint);
}

@end
