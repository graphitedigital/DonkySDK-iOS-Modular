//
//  DGFVisualisation.m
//  GeoFenceModule
//
//  Created by Donky Networks on 30/10/2015.
//  Copyright © 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DGFVisualisation.h"
#import "UIViewController+DNRootViewController.h"

@implementation DGFVisualisation

#pragma mark - MAP Visualisation Tracking Location

+ (void)trackLocationUpdateOnMapViewForLocation:(CLLocation *)userLocation
{
    id rootViewController = [UIViewController applicationRootViewController];
    
    // add the LOCATION UPDATE overlay to the rootViewController.mapView
    if ([rootViewController respondsToSelector:@selector(mapView)]) {
        if ([[rootViewController mapView] isKindOfClass:[MKMapView class]]) {
            MKCircle *locationCircle = [MKCircle circleWithCenterCoordinate:userLocation.coordinate radius:userLocation.horizontalAccuracy];
            [locationCircle setTitle:[DGFVisualisation locationAccuracyCoding:userLocation]];
            [locationCircle setSubtitle:@""];
            
            // as the location track is perminent it should not be removed
            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                [[rootViewController mapView] addOverlay:locationCircle];
            }];
        }
    }
}

+ (NSString*)locationAccuracyCoding:(CLLocation*)userLocation
{
    if ((userLocation.horizontalAccuracy >= 100))
    {
        return @"100+";
    }
    if ((userLocation.horizontalAccuracy >= 50))
    {
        return @"50+";
    }
    if ((userLocation.horizontalAccuracy >= 20))
    {
        return @"20+";
    }
    if ((userLocation.horizontalAccuracy >= 10))
    {
        return @"10+";
    }
    return @"<10";
}

#pragma mark - MapKit Visualisation OVERLAYS

+ (void)addOverlayForRegionUsingDictionary:(NSDictionary*)dictionary
{
    NSDictionary *centrePoint = dictionary[@"centrePoint"];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([centrePoint[@"latitude"] doubleValue],
                                                              [centrePoint[@"longitude"] doubleValue]);
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:coord
                                                     radius:[dictionary[@"radiusMetres"] integerValue]];
    
    if (dictionary[@"timeEntered"]) {
        [circle setTitle:@"ENTERED"];
    }
    if (dictionary[@"timeLeft"]) {
        [circle setTitle:@"EXITED"];
    }
    [circle setSubtitle:dictionary[@"id"]];
    [self addOverlayForCircle:circle];
}

+ (void)addOverlayForCircle:(MKCircle*)circle
{
    id rootViewController = [UIViewController applicationRootViewController];
    
    // add the GEOFENCE overlay to the rootViewController.mapView
    if ([rootViewController respondsToSelector:@selector(mapView)]) {
        if ([[rootViewController mapView] isKindOfClass:[MKMapView class]]) {
            SEL removeAndAddOverlay = NSSelectorFromString(@"removeAndAddGeoFenceOverlay:");
            if ([rootViewController respondsToSelector:removeAndAddOverlay]) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                    ((void (*)(id, SEL, MKCircle *))[rootViewController methodForSelector:removeAndAddOverlay])(rootViewController, removeAndAddOverlay, circle);
                }];
            }
        }
    }
}

+ (void)removeAllOverlays
{
    id rootViewController = [UIViewController applicationRootViewController];
    
    if ([rootViewController respondsToSelector:@selector(mapView)]) {
        if ([[rootViewController mapView] isKindOfClass:[MKMapView class]]) {
            if ([rootViewController respondsToSelector:@selector(removeAllOverlays)]) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                    [rootViewController removeAllOverlays];
                }];
            }
        }
    }
}

+ (void)removeOverlayForID:(NSString*)iD
{
    if (iD.length) {
        id rootViewController = [UIViewController applicationRootViewController];
        
        // add the GEOFENCE overlay to the rootViewController.mapView
        if ([rootViewController respondsToSelector:@selector(mapView)]) {
            if ([[rootViewController mapView] isKindOfClass:[MKMapView class]]) {
                SEL removeAndAddOverlay = NSSelectorFromString(@"removeGeoFenceOverlayForID:");
                if ([rootViewController respondsToSelector:removeAndAddOverlay]) {
                    // as the location track is perminent it should not be removed
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                        ((void (*)(id, SEL, NSString *))[rootViewController methodForSelector:removeAndAddOverlay])(rootViewController, removeAndAddOverlay, iD);
                    }];
                }
            }
        }
    }
}

#pragma mark - Update MAP Visualisation ENTRY / EXIT

+ (void)displayGeoFenceEntryForFenceID:(NSString*)fenceID
{
    if (fenceID.length) {
        id rootViewController = [UIViewController applicationRootViewController];
        
        // UPDATE GEOFENCE overlay on the rootViewController.mapView to indicate ENTRY
        if ([rootViewController respondsToSelector:@selector(mapView)]) {
            if ([[rootViewController mapView] isKindOfClass:[MKMapView class]]) {
                if ([rootViewController respondsToSelector:@selector(displayGeoFenceEntryForFenceID:)]) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                        [rootViewController displayGeoFenceEntryForFenceID:fenceID];
                    }];
                }
            }
        }
    }
}

+ (void)displayGeoFenceExitForFenceID:(NSString*)fenceID
{
    if (fenceID.length) {
        id rootViewController = [UIViewController applicationRootViewController];
        
        // UPDATE GEOFENCE overlay on the rootViewController.mapView to indicate EXIT
        if ([rootViewController respondsToSelector:@selector(mapView)]) {
            if ([[rootViewController mapView] isKindOfClass:[MKMapView class]]) {
                if ([rootViewController respondsToSelector:@selector(displayGeoFenceExitForFenceID:)]) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                        [rootViewController displayGeoFenceExitForFenceID:fenceID];
                    }];
                }
            }
        }
    }
}

#pragma mark - Update Number of GEOFENCES

+ (void)updateNumberOfFences:(NSInteger)numberOfFences
{
    if (numberOfFences) {
        id rootViewController = [UIViewController applicationRootViewController];
        
        // UPDATE GEOFENCE overlay on the rootViewController.mapView to indicate EXIT
        if ([rootViewController respondsToSelector:@selector(mapView)]) {
            if ([[rootViewController mapView] isKindOfClass:[MKMapView class]]) {
                if ([rootViewController respondsToSelector:@selector(updateNumberOfFences:)]) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [rootViewController updateNumberOfFences:numberOfFences];
                    }];
                }
            }
        }
    }
}

@end
