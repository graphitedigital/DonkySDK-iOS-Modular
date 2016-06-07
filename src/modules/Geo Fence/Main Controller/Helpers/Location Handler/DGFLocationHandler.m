//
//  DGFLocationHandler.m
//  GeoFenceModule
//
//  Created by Donky Networks on 30/10/2015.
//  Copyright © 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DGFLocationHandler.h"
#import "DGFDwellTimer.h"
#import "DLSMainController.h"
#import "DGFVisualisation.h"
#import "DNLoggingController.h"

@interface DGFLocationHandler ()

@property(nonatomic, strong) NSMutableArray *lastFiveMeasurementsOfSpeed;
@property(nonatomic, strong) NSDate *lastAcceptedDeviceLocationUpdateDate;

@end

@implementation DGFLocationHandler

+ (DGFLocationHandler *)sharedInstance
{
    static DGFLocationHandler *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DGFLocationHandler alloc] initPrivate];
    });
    return sharedInstance;
}

- (instancetype)init
{
    return [self initPrivate];
}

- (instancetype)initPrivate
{
    self = [super init];
    
    if (self) {
        // speed measurements
        self.lastFiveMeasurementsOfSpeed = [[NSMutableArray alloc] initWithCapacity:5];
        // last accepted update date
        self.lastAcceptedDeviceLocationUpdateDate = nil;
        // ensure we add a initial control region
        self.controlRegionRadius = 0;
        
        // has device stopped moving ?
        self.isMovingTimer = [NSTimer scheduledTimerWithTimeInterval:kDGFCheckIfDeviceHasMovedAfterSeconds
                                                             target:self
                                                           selector:@selector(locationHandlerIsMoving)
                                                           userInfo:nil
                                                            repeats:YES];
    }
    
    return self;
}

#pragma mark - Handle LOCATION MANAGER updates

- (void)updateLocation:(CLLocation*)locationUpdate fromLocationManager:(CLLocationManager*)locationManager {
    
    // add the mapView if available - NOTE : Visualisation always CURRENTLY shows location measurements
    // ... NO DONT SHOW ones that are not accepted by the processor
    // [DGFVisualisation trackLocationUpdateOnMapViewForLocation:locationUpdate];
    
    if ([locationUpdate horizontalAccuracy] > kDGFIgnoreLocationUpdatesOfHorizontalAccuracyGreaterThan) {
        return;
    }
    
    // Process location UPDATES ...
    
    // check and set the last accepted update date
    NSTimeInterval sinceLastUpdate = [locationUpdate.timestamp timeIntervalSinceDate:self.lastAcceptedDeviceLocationUpdateDate];
    if ((self.lastAcceptedDeviceLocationUpdateDate) && (sinceLastUpdate < kDGFIgnoreLocationUpdatesGeneratedLessThanSecondsAgo)) {
        return;
    }
    
    [DGFVisualisation trackLocationUpdateOnMapViewForLocation:locationUpdate];
    self.lastAcceptedDeviceLocationUpdateDate = [NSDate date];
    
    // Location UPDATE accepted ....
    
    // ignore ones which dont comply to required accurancy
    if ([locationUpdate horizontalAccuracy] <= kDGFIgnoreLocationUpdatesOfHorizontalAccuracyGreaterThan) {
        
        // NOW we have a location update
        [[DGFMainController sharedInstance] setCurrentProcessedLocation:locationUpdate];
        
        // re-sort inMemory based on distance from this location
        [self checkControlRegion];
        
        // walking =  3 miles/hour = 1.34 mps (dwelltime distance = 6.7m)
        // driving = 30 miles/hour = 13.4 mps (dwelltime distance = 67m)
        // update the distance filter based on last x measurements
        
        // check speed in mps ... are we going faster than say walking ?
        if (locationUpdate.speed > (kDGFLocationManager3minimumDistanceFilter / kDGFDistanceFilterConversionFactor)) {
            DNInfoLog(@"%s - speed = %.3f",__FUNCTION__,locationUpdate.speed);
            
            // add one and remove one
            [self.lastFiveMeasurementsOfSpeed addObject:[NSNumber numberWithDouble:locationUpdate.speed]];
            while (self.lastFiveMeasurementsOfSpeed.count > kDGFNumberOfSpeedMeasurements) {
                [self.lastFiveMeasurementsOfSpeed removeObjectAtIndex:0];
            }
            
            // do we have required number of speed measurements
            if (self.lastFiveMeasurementsOfSpeed.count == kDGFNumberOfSpeedMeasurements) {
                
                // calculate the NEW distanceFilter
                double total = 0;
                for (NSNumber *speed in self.lastFiveMeasurementsOfSpeed) {
                    total = total + [speed floatValue];
                }
                double average = (total / kDGFNumberOfSpeedMeasurements) * kDGFDistanceFilterConversionFactor;
                if (average < kDGFLocationManager3minimumDistanceFilter) {
                    average = kDGFLocationManager3minimumDistanceFilter;
                }
                
                // Set the distanceFilter
                // NOTE : lastAcceptedDeviceLocationUpdateDate is required because setting the distanceFilter causes didUpdateLocations to be called !!
                [locationManager setDistanceFilter:average];
                DNInfoLog(@"%s - setDistanceFilter = %li",__FUNCTION__,(long)locationManager.distanceFilter);
            }
        }
        
        // (PAP) only other place this will be required is when the app starts up
        //   (or restarts via UIApplicationLaunchOptionsLocationKey)
        
        // mark dwell Times
        if (locationUpdate) {
                [[DGFDwellTimer sharedInstance] markForDwellTimeCheckAtLocation:locationUpdate.coordinate];
        }
    }
}

- (void)locationHandlerIsMoving
{
    DNInfoLog(@"%s",__FUNCTION__);
    if (self.lastFiveMeasurementsOfSpeed.count == kDGFNumberOfSpeedMeasurements) {
        // force location update by setting the distanceFilter and therefore recalculation
        [[DLSMainController locationServicesManager] setDistanceFilter:0];
        DNInfoLog(@"%s set to 0",__FUNCTION__);
    }
}

- (void)updateWithUserSelectedLocation:(CLLocationCoordinate2D)userLocationCoordinate
{
    // update location
    CLLocation *locationUpdate = [[CLLocation alloc] initWithLatitude:userLocationCoordinate.latitude longitude:userLocationCoordinate.longitude];
    [[DGFMainController sharedInstance] setCurrentProcessedLocation:locationUpdate];
    
    // are we still in the control region
    [self checkControlRegion];
    
    // dwelltime
    [[DGFDwellTimer sharedInstance] markForDwellTimeCheckAtLocation:userLocationCoordinate];
}

#pragma mark - Control Region

- (void)checkControlRegion
{
    // not yet defined so create it
    if (!self.controlRegionRadius) {
        [self sortGeofencesInMemoryFromCurrentLocation];
        return;
    }
    
    MKMapPoint currentProcessedLocationPoint = MKMapPointForCoordinate([[[DGFMainController sharedInstance] currentProcessedLocation] coordinate]);
    MKMapPoint controlRegionPoint = MKMapPointForCoordinate(self.controlRegionCentreCoordinate);
    CLLocationDistance distance = MKMetersBetweenMapPoints(currentProcessedLocationPoint, controlRegionPoint);
    
    // are we inside the control fence
    if (self.controlRegionRadius > distance) {
    }
    // we are outside the control fence ... then recalculate control fence
    else
    {
        [self sortGeofencesInMemoryFromCurrentLocation];
    }
}

- (void)sortGeofencesInMemoryFromCurrentLocation
{
    DNInfoLog(@"%s - START",__FUNCTION__);
    DNInfoLog(@"%f : %s - START %lu",[[NSDate date] timeIntervalSince1970],__FUNCTION__,(unsigned long)[[DGFMainController sharedInstance] regionsInMemory].count);
    
    [[[DGFMainController sharedInstance] regionsInMemory] sortUsingComparator:^NSComparisonResult(id o1, id o2)
     {
         NSDictionary *centrePoint1 = o1[@"centrePoint"];
         NSDictionary *centrePoint2 = o2[@"centrePoint"];
         
         CLLocationCoordinate2D m1 = CLLocationCoordinate2DMake([centrePoint1[@"latitude"] doubleValue],
                                                                [centrePoint1[@"longitude"] doubleValue]);
         CLLocationCoordinate2D m2 = CLLocationCoordinate2DMake([centrePoint2[@"latitude"] doubleValue],
                                                                [centrePoint2[@"longitude"] doubleValue]);
         
         MKMapPoint mapPointLocation = MKMapPointForCoordinate([[[DGFMainController sharedInstance] currentProcessedLocation] coordinate]);
         MKMapPoint mapPointpoint1 = MKMapPointForCoordinate(m1);
         MKMapPoint mapPointpoint2 = MKMapPointForCoordinate(m2);
         CLLocationDistance distance1 = MKMetersBetweenMapPoints(mapPointpoint1, mapPointLocation);
         CLLocationDistance distance2 = MKMetersBetweenMapPoints(mapPointpoint2, mapPointLocation);
         
         return distance1 < distance2 ? NSOrderedAscending : distance1 > distance2 ? NSOrderedDescending : NSOrderedSame;
     }];
    
    // inMemory Changed so update monitored control region
    [self addMonitoredControlRegionAtLocation:[[[DGFMainController sharedInstance] currentProcessedLocation] coordinate]];
    
    DNInfoLog(@"%s - END",__FUNCTION__);
    DNInfoLog(@"%f : %s - END %lu",[[NSDate date] timeIntervalSince1970],__FUNCTION__,(unsigned long)[[DGFMainController sharedInstance] regionsInMemory].count);
}

#pragma mark - InMemory Geofence State -> CLLOCATION Monitored Regions

- (void)addMonitoredControlRegionAtLocation:(CLLocationCoordinate2D)location
{
    MKMapPoint mapPointForLocation = MKMapPointForCoordinate(location);
    
    int countOfClosestNumberOfFences = 0;
    CLLocationDistance sizeOfControlRegionMetres = kDGFMaximumSizeOfControlRegionMetres;
    
    for (NSMutableDictionary *inMemoryDictionary in [[DGFMainController sharedInstance] regionsInMemory]) {
        
        // monitor the fence
        CLLocationCoordinate2D fenceCoordinate = [self regionCentreCoordinateUsingDictionary:inMemoryDictionary[@"centrePoint"]];
        
        // distance from location to centre of fence
        MKMapPoint mapPointForFence = MKMapPointForCoordinate(fenceCoordinate);
        CLLocationDistance distanceFromLocationToFenceCentre = MKMetersBetweenMapPoints(mapPointForLocation, mapPointForFence);
        CLLocationDistance fenceRadius = [inMemoryDictionary[@"radiusMetres"] floatValue];
        
        // inside the fence
        if (fenceRadius > distanceFromLocationToFenceCentre) {
            CLLocationDistance distanceToBoundary = fenceRadius - distanceFromLocationToFenceCentre;
            if (sizeOfControlRegionMetres > distanceToBoundary ) {
                sizeOfControlRegionMetres = distanceToBoundary;
            }
        }
        // outside the fence
        else
        {
            CLLocationDistance distanceToBoundary = distanceFromLocationToFenceCentre - fenceRadius;
            if (sizeOfControlRegionMetres > distanceToBoundary) {
                sizeOfControlRegionMetres = distanceToBoundary;
            }
        }
        countOfClosestNumberOfFences++;
        if (countOfClosestNumberOfFences == kDGFNumberOfClosestFencesUsedToDefineControlRegion) {
            break;
        }
    }
    
    // check for minimum
    if (sizeOfControlRegionMetres < kDGFMinimumSizeOfControlRegionMetres) {
        sizeOfControlRegionMetres = kDGFMinimumSizeOfControlRegionMetres;
    }
    
    [self setControlRegionCentreCoordinate:location];
    [self setControlRegionRadius:sizeOfControlRegionMetres];
    
    if ([DLSMainController locationServicesManager]) {
        
        // add the control region
        [self addGeoFenceForControlRegion];
        
        // add the overlay
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:location
                                                         radius:sizeOfControlRegionMetres];
        [circle setSubtitle:kDGFidForGeoFenceControlRegion];
        [DGFVisualisation addOverlayForCircle:circle];
    }
    
    // add a some addtional closest ones ?
    if (kDGFAdditionalMonitoredFences) {
        int additionalMonitoredFencesCount = 0;
        for (NSMutableDictionary *inMemoryDictionary in [[DGFMainController sharedInstance] regionsInMemory]) {
            [self monitorGeofenceUsingDictionary:inMemoryDictionary];
            additionalMonitoredFencesCount++;
            if (additionalMonitoredFencesCount == kDGFAdditionalMonitoredFences) {
                break;
            }
        }
    }
}

- (void)addGeoFenceForControlRegion
{
    // if has radius add
    if ([[DGFLocationHandler sharedInstance] controlRegionRadius]) {
        CLCircularRegion *monitoredControlRegion = [[CLCircularRegion alloc] initWithCenter:[[DGFLocationHandler sharedInstance] controlRegionCentreCoordinate]
                                                                                     radius:[[DGFLocationHandler sharedInstance] controlRegionRadius]
                                                                                 identifier:kDGFidForGeoFenceControlRegion];
        [[DLSMainController locationServicesManager] startMonitoringForRegion:monitoredControlRegion];
    }
}

- (CLLocationCoordinate2D)monitorGeofenceUsingDictionary:(NSDictionary*)dictionary
{
    CLLocationCoordinate2D coordinate = [self regionCentreCoordinateUsingDictionary:dictionary[@"centrePoint"]];
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:coordinate radius:[dictionary[@"radiusMetres"] integerValue] identifier:dictionary[@"id"]];
    
    if ([DLSMainController locationServicesManager]) {
        [[DLSMainController locationServicesManager] startMonitoringForRegion:region];
        region.notifyOnEntry = YES;
        region.notifyOnExit = YES;
        
        [DGFVisualisation addOverlayForRegionUsingDictionary:dictionary];
    }
    return coordinate;
}

- (CLLocationCoordinate2D)regionCentreCoordinateUsingDictionary:(NSDictionary*)dictionary
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([dictionary[@"latitude"] doubleValue],
                                                                   [dictionary[@"longitude"] doubleValue]);
    return coordinate;
}

@end
