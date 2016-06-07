//
//  DGFMainController.m
//  GeoFenceModule
//
//  Created by Chris Watson on 19/05/2015.
//  Copyright (c) 2015 Chris Watson. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DGFMainController.h"
#import "DNDonkyCore.h"
#import "DNConstants.h"
#import "DLSMainController.h"
#import "DNClientNotification.h"
#import "DNNetworkController.h"
#import "DNDataController.h"
#import "DNLoggingController.h"
#import "NSManagedObject+DNHelper.h"
#import "NSDate+DNDateHelper.h"
#import "NSMutableDictionary+DNDictionary.h"
#import "DCAAnalyticsController.h"
#import "DAAutomationController.h"
#import "DGFVisualisation.h"
#import "DNSubscription.h"

@interface DGFMainController ()

@property (nonatomic, strong) DLSMainController *donkyLocationServices;
@property (nonatomic, strong) NSMutableDictionary *timeSpentTimers;
@property (nonatomic, strong) DNModuleDefinition *moduleDefinition;
@property (nonatomic, strong) DGFTriggerManager *triggerManager;
@property (nonatomic, strong) DGFRegionManager *regionManager;

@property (nonatomic, copy) DNSubscriptionBatchHandler triggerConfiguration;
@property (nonatomic, copy) DNSubscriptionBatchHandler triggerDeleted;
@property (nonatomic, copy) DNSubscriptionBatchHandler regionCreated;
@property (nonatomic, copy) DNSubscriptionBatchHandler regionDeleted;

@property (nonatomic, copy) DNLocalEventHandler simulateGeoFenceEntry;
@property (nonatomic, copy) DNLocalEventHandler simulateGeoFenceExit;
@property (nonatomic, copy) DNLocalEventHandler locationUpdates;

@property (nonatomic) BOOL geoFenceModulePauseDueToBatteryLevel;
@property (nonatomic) BOOL hasUserBeenRegistered;

@end

@implementation DGFMainController

#pragma mark - Controller Life Cycle

+(DGFMainController *)sharedInstance {
    static DGFMainController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DGFMainController alloc] initPrivate];
    });
    return sharedInstance;
}

-(instancetype)init {
    return [DGFMainController sharedInstance];
}

-(instancetype)initPrivate {
    self = [super init];
    
    if (self) {

        [self setRegionsInMemory:[[NSMutableArray alloc] init]];
        [self setTimeSpentTimers:[[NSMutableDictionary alloc] init]];
        
        // dwell timer
        [[DGFDwellTimer sharedInstance] setIsTrackingGeoFences:NO];

        // kDGFidForGeoFenceControlRegion will only be present if Geo Module is implemented ...
        // MUST be able to monitor this GeoFence, so if it fails REMOVE one of the Implementor ones ...
        [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDLSLocationManagerMonitoringDidFailForRegion handler:^(DNLocalEvent *event) {
           
            NSDictionary *data = [event data];
            
            CLLocationManager *manager = (CLLocationManager*)data[@"locationManager"];
            CLRegion *region = (CLRegion*)data[@"region"];
            NSError *error = (NSError*)data[@"error"];
            
            if ([[region identifier] isEqualToString:kDGFidForGeoFenceControlRegion]) {
                // is this a FAIL when adding GeoFence Control Region ?
                if ([error code] == 5) {
                    DNErrorLog(@"FAILED to add Monitoring for kDGFidForGeoFenceControlRegion");
                    NSSet *monitoredRegions = [manager monitoredRegions];
                    // if equal to the max
                    if (monitoredRegions.count == kDGFLocationManagerMaxNumberOfRegionsThanCanBeMonitored) {
                        // remove one of the implementers monitored regions - AT RANDOM !!
                        id remove = [monitoredRegions anyObject];
                        DNErrorLog(@"REMOVING Monitoring for %@",remove);
                        [manager stopMonitoringForRegion:remove];
                        // re-add control fence
                        [[DGFLocationHandler sharedInstance] addGeoFenceForControlRegion];
                    }
                }
            }
        }];
    }

    return self;
}

#pragma mark - GeoFence Manager START / STOP

- (void)start {

    // start tracking fences
    [[DGFMainController sharedInstance] startTrackingGeoFences];
    
    //Create region manager
    [self setRegionManager:[[DGFRegionManager alloc] init]];
    //Create trigger manager
    [self setTriggerManager:[[DGFTriggerManager alloc] init]];

    // We register the module to so this is updated on the backend-purely for visibility:
    [self setModuleDefinition:[[DNModuleDefinition alloc] initWithName:NSStringFromClass([self class]) version:@"1.0.0.0"]];

    __weak typeof(self) weakSelf = self;

    //Subscribe to Donky notifications:
    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDNEventRegistration handler:^(DNLocalEvent *event) {
        // check if just update
        BOOL wasUpdate = [[event data][@"IsUpdate"] boolValue];
        if ((!wasUpdate) && (!weakSelf.hasUserBeenRegistered)) {
            [weakSelf setHasUserBeenRegistered:YES];
            [weakSelf newRegistration:(NSDictionary*)[event data]];
        }
    }];

    // NEW TRIGGER
    [self setTriggerConfiguration:^(NSArray *batch) {
        __block NSMutableArray *acknowledgeArray = [[NSMutableArray alloc] init];
        
        [batch enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

            NSManagedObjectContext *temporaryContext = [DNDataController temporaryContext];
            DNInfoLog(@"Trigger DATA Insert : %@", [obj data]);
            NSDictionary *objectData = [obj data];
            [[weakSelf triggerManager] insertNewTriggerDefinition:[obj data]];

            // MUST NOT acknowledged UNTIL we have its REGION !
            BOOL haveAllRegions = YES;
            NSArray *regions = objectData[@"triggerData"][@"regions"];
            // check we have the regions
            for (NSDictionary *region in regions) {
                NSString *regionID = region[@"id"];
                DNRegion *regionInCoreData = [DNRegion fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"regionID == %@", regionID] withContext:temporaryContext includesPendingChanges:NO];
                DNInfoLog(@"Trigger DATA Insert - regionID : %@",regionInCoreData.regionID);
                if (![regionInCoreData.regionID isEqualToString:regionID]) {
                    haveAllRegions = NO;
                }
            }

            // acknowledge its receipt
            DNClientNotification *acknowledge = [[DNClientNotification alloc] initWithAcknowledgementNotification:obj];
            [[acknowledge acknowledgementDetails] setValue:@"Delivered" forKey:@"Result"];
            if (acknowledge) {
                if ((haveAllRegions) || (regions.count)) {
                    [acknowledgeArray addObject:acknowledge];
                }
            }
        }];

        [[DNNetworkController sharedInstance] queueClientNotifications:acknowledgeArray completion:^(id data) {
            [[DNNetworkController sharedInstance] synchronise];
        }];
    }];


    [self setTriggerDeleted:^(NSArray *batch) {
        __block NSMutableArray *acknowledgeArray = [[NSMutableArray alloc] init];
        [batch enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

            DNInfoLog(@"Trigger DATA Delete : %@", [obj data]);
            [[weakSelf triggerManager] deleteTriggerDefinition:[obj data]];

            // acknowledge its receipt
            DNClientNotification *acknowledge = [[DNClientNotification alloc] initWithAcknowledgementNotification:obj];
            [[acknowledge acknowledgementDetails] setValue:@"Delivered" forKey:@"Result"];
            if (acknowledge) {
                [acknowledgeArray addObject:acknowledge];
            }
        }];

        [[DNNetworkController sharedInstance] queueClientNotifications:acknowledgeArray completion:^(id data) {
            [[DNNetworkController sharedInstance] synchronise];
        }];
    }];

    // NEW REGION
    [self setRegionCreated:^(NSArray *batch) {
//        __block NSMutableArray *acknowledgeArray = [[NSMutableArray alloc] init];

        NSManagedObjectContext *temporaryContext = [DNDataController temporaryContext];

        [temporaryContext performBlock:^{
            [batch enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                DNServerNotification *serverNotification = obj;
                NSDictionary *regionData = [serverNotification data][@"location"];
                DNInfoLog(@"Region DATA Insert : %@", regionData);
                [[weakSelf regionManager] insertNewRegionDefinition:regionData context:temporaryContext serverNotification:obj];
                [weakSelf insertGeofenceInMemoryUsingDictionary:regionData];
            }];

            [[DNDataController sharedInstance] saveContext:temporaryContext completion:^(id data) {
                [[DGFDwellTimer sharedInstance] markForDwellTimeCheckAtCurrentLocation];
                [[DNNetworkController sharedInstance] synchronise];
            }];
        }];
    }];

    // DELETE REGION
    [self setRegionDeleted:^(NSArray *batch) {
        __block NSMutableArray *acknowledgeArray = [[NSMutableArray alloc] init];
        [batch enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

            DNInfoLog(@"Region DATA Delete : %@", [obj data]);

            // remove from inMemory
            [weakSelf deleteGeofenceInMemoryUsingDictionary:[obj data]];
            // remove overlay
            [DGFVisualisation removeOverlayForID:[obj data][@"id"]];
            // remove from CoreData
            [[weakSelf regionManager] deleteRegionDefinition:[obj data]];

            // acknowledge its receipt
            DNClientNotification *acknowledge = [[DNClientNotification alloc] initWithAcknowledgementNotification:obj];
            [[acknowledge acknowledgementDetails] setValue:@"Delivered" forKey:@"Result"];
            if (acknowledge) {
                [acknowledgeArray addObject:acknowledge];
            }
        }];
        // sort them
        [[DGFLocationHandler sharedInstance] sortGeofencesInMemoryFromCurrentLocation];

        [[DNNetworkController sharedInstance] queueClientNotifications:acknowledgeArray];
    }];

    [self setTriggerCreatedSubscription:[[DNSubscription alloc] initWithNotificationType:kDGFTriggerConfigurationNotification batchHandler:[self triggerConfiguration]]];
    [[self triggerCreatedSubscription] setAutoAcknowledge:NO];

    [self setTriggerDeletedSubscription:[[DNSubscription alloc] initWithNotificationType:kDGFTriggerDeletedNotification batchHandler:[self triggerDeleted]]];

    [self setRegionCreatedSubscription:[[DNSubscription alloc] initWithNotificationType:kDGFStartTrackingLocationNotification batchHandler:[self regionCreated]]];
    [[self regionCreatedSubscription] setAutoAcknowledge:NO];

    [self setRegionDeletedSubscription:[[DNSubscription alloc] initWithNotificationType:kDGFStopTrackingLocationNotification batchHandler:[self regionDeleted]]];

    [[DNDonkyCore sharedInstance] subscribeToDonkyNotifications:[self moduleDefinition] subscriptions:@[[self triggerCreatedSubscription], [self triggerDeletedSubscription], [self regionCreatedSubscription], [self regionDeletedSubscription]]];

    [[DLSMainController sharedInstance] startAlwaysUsage];

    // configure the default behaviour of the location manager for Geo Module
    [[DLSMainController locationServicesManager] setDesiredAccuracy:kDGFlLocationManager1desiredAccuracy];
    [[DLSMainController locationServicesManager] setActivityType:kDGFLocationManager2activityType];

    // (NOTE) After started the distance filter can be set depending on the
    //        speed at which the device is travelling over time !!
    //        (see didUpdateLocations:)
    [[DLSMainController locationServicesManager] setDistanceFilter:kDGFLocationManager3minimumDistanceFilter];

    // Create new message handler:
    [self setLocationUpdates:^(DNLocalEvent *event) {
        // ... when it occurs, get the details received from the event
        NSArray *locations = [event data][@"locations"];
        CLLocation *location = [locations lastObject];
        CLLocationManager *manager = [event data][@"locationManager"];
        [[DGFLocationHandler sharedInstance] updateLocation:location fromLocationManager:manager];
    }];

    // Subscribe to the new message event:
    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDLSLocationManagerDidUpdateLocations handler:[self locationUpdates]];

    // listen for the authorisation change event
    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDLSLocationManagerDidChangeAuthorizationStatus handler:^(DNLocalEvent *event) {
        [weakSelf processLocationAuthorisationStatusChange:event];
    }];


    [self setSimulateGeoFenceEntry:^(DNLocalEvent *event) {

        NSString *name = [event data][@"name"];
        NSString *id = [event data][@"id"];

        if (name) {
            [weakSelf simulateGeoFenceEntryWithName:name];
        }
        else if (id) {
            [weakSelf simulateGeoFenceEntryWithID:id];
        }
    }];

    [self setSimulateGeoFenceExit:^(DNLocalEvent *event) {

        NSString *name = [event data][@"name"];
        NSString *id = [event data][@"id"];

        if (name) {
            [weakSelf simulateGeoFenceExitWithName:name];
        }
        else if (id) {
            [weakSelf simulateGeoFenceExitWithID:id];
        }
    }];

    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDFSimulateGeoFenceExit handler:[self simulateGeoFenceExit]];
    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDFSimulateGeoFenceEntry handler:[self simulateGeoFenceEntry]];

    // get the regions we already have
    [self getCurrentRegionsOnDevice];

    // check for battery changes
    if (kDGFEnableAutoPowerSaveOption) {

        [UIDevice currentDevice].batteryMonitoringEnabled = YES;

        // Register for battery level and state change notifications.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(batteryLevelChanged:)
                                                     name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    }

    [self batteryLevelChanged:nil];
}

- (void)stop {
    if ([self triggerCreatedSubscription] && [self triggerCreatedSubscription] && [self regionCreatedSubscription] && [self regionDeletedSubscription]) {
        [[DNDonkyCore sharedInstance] unSubscribeToDonkyNotifications:self.moduleDefinition subscriptions:@[[self triggerCreatedSubscription], [self triggerDeletedSubscription], [self regionCreatedSubscription], [self regionDeletedSubscription]]];
    }
    
    // invalidate handler isMovingTimer
    [[[DGFLocationHandler sharedInstance] isMovingTimer] invalidate];
    [[DGFLocationHandler sharedInstance] setIsMovingTimer:nil];

    [[self donkyLocationServices] stopLocationUpdates];
}

#pragma mark - Battery Level Change

- (void)batteryLevelChanged:(NSNotification *)notification {
    
    float batteryLevel = [UIDevice currentDevice].batteryLevel;
    
    // battery less than 15%
    if (kDGFEnableAutoPowerSaveOption) {
        if (batteryLevel < kDGFAutoPowerSaveOptionMinimumBatteryLevel) {
            self.geoFenceModulePauseDueToBatteryLevel = YES;
            [self stopTrackingGeoFences];
            [[DLSMainController sharedInstance] stopLocationUpdates];
        } else {
            if (self.geoFenceModulePauseDueToBatteryLevel) {
                self.geoFenceModulePauseDueToBatteryLevel = NO;
                [[DLSMainController sharedInstance] startLocationUpdates];
                [self startTrackingGeoFences];
            }
        }
    }
}

#pragma mark - Authorisation Change

- (void)processLocationAuthorisationStatusChange:(DNLocalEvent*)event
{
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    DNInfoLog(@"%i", status);
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            break;
        case kCLAuthorizationStatusRestricted:
            // remove control
            [self stopTrackingGeoFences];
            break;
        case kCLAuthorizationStatusDenied:
            // remove control
            [self stopTrackingGeoFences];
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            // OK
            [self startTrackingGeoFences];
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            // OK
            [self startTrackingGeoFences];
            break;
        default:
            break;
    }
}

#pragma mark - New Registration

- (void)newRegistration:(NSDictionary*)data {
    
    DNInfoLog(@"%@",data);
    
    // remove existing regionsInMemory
    [self.regionsInMemory removeAllObjects];
    // remove overlays
    [DGFVisualisation removeAllOverlays];
    
    // delete all the Geo data
    [self.regionManager deleteAllRegions];
    [self.triggerManager deleteAllTriggers];
    
    // get the NEW data
    __weak typeof(self) weakSelf = self;

    // FIRST ... get regions
    [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:YES route:kDNNetworkGetActiveRegions httpMethod:DNGet parameters:nil success:^(NSURLSessionDataTask *task, id responseData) {
        
        DNInfoLog(@"NEW REGISTRATION - Region DATA Insert");
        DNInfoLog(@"Start - NEW REGISTRATION : Process REGIONS");

        //Create a context here:
        NSManagedObjectContext *temporaryContext = [DNDataController temporaryContext];

        [temporaryContext performBlock:^{
            [responseData enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger idx, BOOL *stop) {
                [[weakSelf regionManager] insertNewRegionDefinition:dictionary context:temporaryContext serverNotification:nil];
                [weakSelf insertGeofenceInMemoryUsingDictionary:dictionary];
            }];

            [[DNDataController sharedInstance] saveContext:temporaryContext completion:nil];
        }];

        DNInfoLog(@"END - NEW REGISTRATION : Process REGIONS %lu",(unsigned long)self.regionsInMemory.count);
        
        // THEN ... get all triggers
        [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:YES route:kDNNetworkGetActiveTriggers httpMethod:DNGet parameters:nil success:^(NSURLSessionDataTask *task2, id responseData2) {
            DNInfoLog(@"NEW REGISTRATION - Trigger DATA Insert");
            DNInfoLog(@"Start - NEW REGISTRATION : Process TRIGGERS");
            [responseData enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger idx, BOOL *stop) {
                //DNInfoLog(@"NEW REGISTRATION - Trigger DATA Insert : %@", dictionary);
                [[weakSelf triggerManager] insertNewTriggerDefinition:dictionary];
            }];
            DNInfoLog(@"END - NEW REGISTRATION : Process TRIGGERS");
            
            // FINALLY ... mark mark any regions were are currently in for dwelltime
            [[DGFDwellTimer sharedInstance] markForDwellTimeCheckAtCurrentLocation];
        }
        failure:^(NSURLSessionDataTask *task2, NSError *error) {
            DNErrorLog(@"%@", error);
        }];
    }
        failure:^(NSURLSessionDataTask *task, NSError *error) {
            DNErrorLog(@"%@", error);
    }];

}

#pragma mark - Fence CROSSINGS

- (void)fenceCrossingForRegionID:(NSString*)regionID
                     inDirection:(DGFTriggerRegionDirection)direction
                    timeInRegion:(NSTimeInterval)timeInRegion;
{
    // check triggers
    [self checkTriggersForRegionID:regionID inDirection:direction atLocation:self.currentProcessedLocation.coordinate];
    // update analytics
    [self updateAnalyticsForRegionID:regionID inDirection:direction atLocation:self.currentProcessedLocation timeInRegion:timeInRegion];
    
    if (direction == DGFTriggerRegionDirectionOut) {
        // EXIT
        // invalidate any timers
        [self removeTimersForRegionID:regionID];
        
        // update visualisation
        [DGFVisualisation displayGeoFenceExitForFenceID:regionID];
    }
    else
    {
        // ENTRY
        // update visualisation
        [DGFVisualisation displayGeoFenceEntryForFenceID:regionID];
    }
    
    DGFGeoFenceCrossing geofenceCrossing;
    if (direction == DGFTriggerRegionDirectionOut) {
        geofenceCrossing = DGFGeoFenceCrossingExit;
    } else {
        geofenceCrossing = DGFGeoFenceCrossingEntry;
    }
    //Do we have a Any completion blocks ?
    if ([[self.regionManager geoFenceUpdateBlocks] count]) {
        [[self.regionManager geoFenceUpdateBlocks] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            DGFGeoFenceCrossingUpdateBlock crossingBlock = obj;
            crossingBlock(geofenceCrossing, regionID);
        }];
    }
}

#pragma mark - Update ANALYTICS

- (void)updateAnalyticsForRegionID:(NSString*)regionID
                       inDirection:(DGFTriggerRegionDirection)direction
                        atLocation:(CLLocation*)location
                      timeInRegion:(NSTimeInterval)timeInRegion;
{
    if (direction == DGFTriggerRegionDirectionOut) {
        DNInfoLog(@"Analytics update for EXIT region %@", regionID);
    }
    if (direction == DGFTriggerRegionDirectionIn) {
        DNInfoLog(@"Analytics update for ENTRY region %@", regionID);
    }
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data dnSetObject:regionID forKey:@"Id"];
    [data dnSetObject:direction == DGFTriggerRegionDirectionIn ? @"Entering" : @"Exiting" forKey:@"Direction"];
    [data dnSetObject:[[NSDate date] donkyDateForServer] forKey:@"Timestamp"];
    [data dnSetObject:isnan(timeInRegion) ? @(0) : @((int)timeInRegion) forKey:@"TimeInRegionSeconds"];
    
    // Create centre point:
    if (location) {
        NSDictionary *centrePoint = @{@"Latitude" : @(location.coordinate.latitude), @"Longitude" : @(location.coordinate.longitude)};
        [data dnSetObject:centrePoint forKey:@"Location"];
    }
    
    // post analytics for GeoFence Crossing
    [DCAAnalyticsController recordGeoFenceCrossing:data];
}

#pragma mark - InMemory Geofence State

- (void)getCurrentRegionsOnDevice
{
    [[NSDate date] timeIntervalSince1970];
    DNInfoLog(@"%f : %s - START %lu",[[NSDate date] timeIntervalSince1970],__FUNCTION__,(unsigned long)[[DGFMainController sharedInstance] regionsInMemory].count);
    // get region data from device
    NSArray *regionsOnDeviceInMemoryFormat = [[self regionManager] regionsOnDeviceInMemoryFormat];
    [self.regionsInMemory addObjectsFromArray:regionsOnDeviceInMemoryFormat];
    
    [DGFVisualisation updateNumberOfFences:self.regionsInMemory.count];
    
    // add the overlays
    for (NSMutableDictionary *inMemoryData in self.regionsInMemory) {
        [DGFVisualisation addOverlayForRegionUsingDictionary:inMemoryData];
    }
    DNInfoLog(@"%f : %s - END %lu",[[NSDate date] timeIntervalSince1970],__FUNCTION__,(unsigned long)[[DGFMainController sharedInstance] regionsInMemory].count);
}

- (void)insertGeofenceInMemoryUsingDictionary:(NSDictionary*)dictionary
{
    // *** NSLog(@"%f : %s - START %lu",[[NSDate date] timeIntervalSince1970],__FUNCTION__,(unsigned long)[[DGFMainController sharedInstance] regionsInMemory].count);
    if (dictionary) {
        
        NSMutableDictionary *inMemoryData = [self createInMemoryDataUsingDictionary:dictionary];
        
        if (inMemoryData) {
            
            if (inMemoryData[@"id"]) {
                NSPredicate *filter = [NSPredicate predicateWithFormat:@"id = %@",inMemoryData[@"id"]];
                NSArray *filtered = [self.regionsInMemory filteredArrayUsingPredicate:filter];
                
                if (!filtered.count) {
                    // add to regionsInMemory
                    [[self regionsInMemory] addObject:inMemoryData];
                    // add overlay
                    [DGFVisualisation addOverlayForRegionUsingDictionary:inMemoryData];
                    [DGFVisualisation updateNumberOfFences:[[self regionsInMemory] count]];
                }
            }
        }
    }
    // *** NSLog(@"%f : %s - END %lu",[[NSDate date] timeIntervalSince1970],__FUNCTION__,(unsigned long)[[DGFMainController sharedInstance] regionsInMemory].count);
}

- (void)deleteGeofenceInMemoryUsingDictionary:(NSDictionary*)dictionary
{
    if (dictionary) {
        if (dictionary[@"id"]) {
            NSPredicate *filter = [NSPredicate predicateWithFormat:@"id = %@",dictionary[@"id"]];
            NSArray *filtered = [self.regionsInMemory filteredArrayUsingPredicate:filter];
            if (filtered.count) {
                [self.regionsInMemory removeObject:[filtered lastObject]];
            }
        }
    }
}

- (NSMutableDictionary*)createInMemoryDataUsingDictionary:(NSDictionary*)regionData
{
    NSMutableDictionary *inMemoryData = [[NSMutableDictionary alloc] init];
    NSArray *keys = @[@"id", @"name", @"radiusMetres", @"centrePoint", @"status",@"timeEntered"];
    
    for (NSString *key in keys) {
        if (regionData[key]) {
            inMemoryData[key] = regionData[key];
        }
    }
    return inMemoryData;
}

- (void)checkTriggersForRegionID:(NSString*)regionID inDirection:(DGFTriggerRegionDirection)direction atLocation:(CLLocationCoordinate2D)location;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSManagedObjectContext *temporaryContext = [DNDataController temporaryContext];
        DNRegion *region = [DNRegion fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"regionID == %@", regionID] withContext:temporaryContext includesPendingChanges:NO];
        if (region) {
            NSArray *triggers = [[region relatedTriggers] allObjects];
            for (NSDictionary *trigger in triggers) {
                if ((trigger[@"triggerId"]) && ([trigger[@"status"] isEqualToString:@"Active"])) {
                    DNTrigger *triggerData = [DNTrigger fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"triggerId == %@", trigger[@"triggerId"]] withContext:temporaryContext includesPendingChanges:NO];

                    if (triggerData) {
                        BOOL canProceed = [DGFTriggerManager canProceed:triggerData withDirection:direction];
                        if (canProceed) {
                            [self fireTriggerOrTimer:triggerData
                                        forDirection:direction
                                           inContext:temporaryContext
                                          atLocation:location
                                            inRegion:region];
                        }
                    }
                }
            }
        }
    });
}

- (void)fireTrigger:(DNTrigger *)triggerEntity
       forDirection:(DGFTriggerRegionDirection)direction
          inContext:(NSManagedObjectContext *)context
         atLocation:(CLLocationCoordinate2D)location
           inRegion:(DNRegion*)region
{
    
    NSString *text = @"ENTERED";
    if (direction == DGFTriggerRegionDirectionOut) {
        text = @"EXITED";
    }

    DNInfoLog(@"Fire Trigger : %@ for %@ Region : %@", triggerEntity.triggerId,text,region.name);

    @try {
        if ([DGFTriggerManager canProceed:triggerEntity withDirection:direction]) {

            NSMutableDictionary *data = [[NSMutableDictionary alloc] init];

            data[@"type"] = @"TriggerExecuted";
            data[@"radiusMetres"] = [region radiusMetres];
            data[@"triggerDirection"] = @"Both";

            if (direction == DGFTriggerRegionDirectionIn) {
                data[@"triggerDirection"] = @"EnteringRegion";
            }
            if (direction == DGFTriggerRegionDirectionOut) {
                data[@"triggerDirection"] = @"LeavingRegion";
            }

            if (triggerEntity.triggerId != nil) {
                data[@"triggerId"] = triggerEntity.triggerId;
            }
            data[@"triggerType"] = @"Geofence";
            data[@"timeStamp"] = [[NSDate date] donkyDateForServer];
            
            if ((location.latitude != 0) && (location.longitude)) {
                NSDictionary *locationDict = @{@"Latitude" : @(location.latitude), @"Longitude" : @(location.longitude)};
                if ([[locationDict allValues] count] == 2)
                    data[@"centrePoint"] = locationDict;
            }
            else {
                DNErrorLog(@"Error retrieving users location. Omiting location data from client notification...");
            }
            
            data[@"IsFirstExecuted"] = triggerEntity.lastExecuted ? @"false" : @"true";
            
            // post analytics for Trigger firing
            [DCAAnalyticsController recordGeoFenceTriggerExecuted:data];
            
            if (![[triggerEntity actionData] count]) {
                DNInfoLog(@"No trigger data for this region.");
                
                // (KEY) execute NON-Pre-deploy = SimplePush / Normal / Rich
                //[DAAutomationController executeThirdPartyTriggerWithKey:[triggerEntity triggerId] customData:nil];
                [DAAutomationController executeThirdPartyTriggerWithKeyImmediately:[triggerEntity triggerId] customData:nil];
            }
        }
        else
            DNErrorLog(@"Cannot fire trigger, check restrictions: %@", [triggerEntity restrictions]);
    }
    
    @catch (NSException *exception) {
        DNErrorLog(@"Fatal exception (%@) when processing network response.... Reporting & Continuing", [exception description]);
        [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil];
    }
}

- (void)fireTriggerOrTimer:(DNTrigger *)triggerEntity
              forDirection:(DGFTriggerRegionDirection)direction
                 inContext:(NSManagedObjectContext *)context
                atLocation:(CLLocationCoordinate2D)location
                  inRegion:(DNRegion*)region
{
    
    // Check if we need to time
    NSInteger timer = [triggerEntity.timeInRegion integerValue];
    if (timer > 0) {
        
        NSDictionary *data = @{
                               @"trigger":triggerEntity,
                               @"longitude": @(location.longitude),
                               @"latitude": @(location.latitude),
                               @"region":region
                               };
        
        NSTimer *countDownTimer = [NSTimer scheduledTimerWithTimeInterval:timer
                                                                   target:self
                                                                 selector:@selector(timerDidFire:)
                                                                 userInfo:data
                                                                  repeats:NO];
        
        self.timeSpentTimers[triggerEntity.triggerId] = countDownTimer;
        
    }
    else {
        [self fireTrigger:triggerEntity
             forDirection:direction
                inContext:context
               atLocation:location
                 inRegion:region];
    }
}
    
- (void)timerDidFire:(NSTimer *)timer {
    
    NSDictionary *userInfo = (NSDictionary*)timer.userInfo;
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake([userInfo[@"latitude"] doubleValue],
                                                                 [userInfo[@"longitude"] doubleValue]);
    
    [self fireTrigger:userInfo[@"trigger"]
         forDirection:DGFTriggerRegionDirectionBoth
            inContext:[DNDataController temporaryContext]
            atLocation:location
             inRegion:userInfo[@"region"]];
    
    DNTrigger *trigger = userInfo[@"trigger"];
    [[self timeSpentTimers] removeObjectForKey:trigger.triggerId];
}

- (void)removeTimersForRegionID:(NSString *)regionID {
    
    if (regionID.length) {
        NSTimer *timer = self.timeSpentTimers[regionID];
        [timer invalidate];
        [self.timeSpentTimers removeObjectForKey:regionID];
    }
}

#pragma mark - (Parity API) - Tracking of GEOFENCES

- (void)startTrackingGeoFences {
    [[DGFDwellTimer sharedInstance] setIsTrackingGeoFences:YES];
}

- (void)stopTrackingGeoFences {
    [[DGFDwellTimer sharedInstance] setIsTrackingGeoFences:NO];
    [DGFVisualisation removeOverlayForID:kDGFidForGeoFenceControlRegion];
}

#pragma mark - (Parity API) - GeoFence Details

// API : returns copy of all active GeoFences
- (NSArray*)allGeoFences {
    return [self.regionsInMemory copy];
}

- (NSArray*)allGeoFencesForGeoFenceID:(NSString*)geoFenceID {
    
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"id = %@",geoFenceID];
    NSArray *filtered = [self.regionsInMemory filteredArrayUsingPredicate:filter];
    return filtered;
}

- (NSArray*)allGeoFencesForGeoFenceName:(NSString*)geoFenceName {

    NSPredicate *filter = [NSPredicate predicateWithFormat:@"name = %@",geoFenceName];
    NSArray *filtered = [self.regionsInMemory filteredArrayUsingPredicate:filter];
    return filtered;
}

#pragma mark - (Parity API) - Triggers Details

- (NSArray*)allTriggersForGeoFenceID:(NSString*)geoFenceID {
    
    NSManagedObjectContext *temporaryContext = [DNDataController temporaryContext];
    DNRegion *region = [DNRegion fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"regionID == %@", geoFenceID] withContext:temporaryContext includesPendingChanges:NO];
    
    NSArray *triggers = nil;
    
    if (region) {
        triggers = [[region relatedTriggers] allObjects];
    }
    return triggers;
}

- (NSArray*)allTriggersForGeoFenceName:(NSString*)geoFenceName {
    
    NSMutableArray *triggers = [[NSMutableArray alloc] init];

    // get all the fences for a name
    NSArray *regionsForGeoFence = [self allGeoFencesForGeoFenceName:geoFenceName];
    // get all fences for a id
    for (NSDictionary *geofenceDictionary in regionsForGeoFence) {
        NSString *geoFenceID = geofenceDictionary[@"id"];
        if (geoFenceID.length) {
            NSArray *triggersForGeoFenceID = [self allTriggersForGeoFenceID:geoFenceID];
            [triggers addObjectsFromArray:triggersForGeoFenceID];
        }
    }
    return [NSArray arrayWithArray:triggers];
}

#pragma mark - GeoFences UPDATES

- (void)registerGeoFenceUpdate:(DGFGeoFenceUpdateBlock)block {
    
    //Save the completion block:
    if (block) {
        [[self.regionManager geoFenceUpdateBlocks] addObject:block];
    }
}

- (void)unregisterGeoFenceUpdate:(DGFGeoFenceUpdateBlock)block {
    
    //remove the completion block:
    if (block) {
        [[self.regionManager geoFenceUpdateBlocks] removeObject:block];
    }
}

#pragma mark - Trigger UPDATES

- (void)registerTriggerUpdate:(DGFTriggerUpdateBlock)block {
    
    //Save the completion block:
    if (block) {
        [[self.triggerManager triggerUpdateBlocks] addObject:block];
    }
}

- (void)unregisterTriggerUpdate:(DGFTriggerUpdateBlock)block {
    
    //remove the completion block:
    if (block) {
        [[self.triggerManager triggerUpdateBlocks] removeObject:block];
    }
}

#pragma mark - GeoFence Crossings:

- (void)registerForGeoFenceCrossing:(DGFGeoFenceCrossingUpdateBlock)block {

    //Save the completion block:
    if (block) {
        [[self.regionManager geoFenceCrossingBlocks] addObject:block];
    }
}

- (void)unregisterForGeoFenceCrossing:(DGFGeoFenceCrossingUpdateBlock)block {

    //remove the completion block:
    if (block) {
        [[self.regionManager geoFenceCrossingBlocks] removeObject:block];
    }
}

#pragma mark - (Parity API) - Trigger FIRED

- (void)registerForTriggerFired:(DGFTriggerFiredUpdateBlock)block {

    //Save the completion block:
    if (block) {
        [[self.triggerManager triggerFiredBlocks] addObject:block];
    }
}

- (void)unregisterForTriggerFired:(DGFTriggerFiredUpdateBlock)block {

    //remove the completion block:
    if (block) {
        [[self.triggerManager triggerFiredBlocks] removeObject:block];
    }
}

#pragma mark - Simulate GeoFence ENTRY / EXIT

- (void)simulateGeoFenceEntryWithName:(NSString*)geoFenceName
{
    NSArray *fences = [[DGFMainController sharedInstance] allGeoFencesForGeoFenceName:geoFenceName];
    
    if (fences.count) {
        DNDebugLog(@"%@", geoFenceName);
        CLLocationCoordinate2D coordinate2D = [self coordinateForGeoFence:fences[0]];
        [self simulateLocationUpdateAt:coordinate2D];
    }
}
- (void)simulateGeoFenceExitWithName:(NSString*)geoFenceName
{
    NSArray *fences = [[DGFMainController sharedInstance] allGeoFencesForGeoFenceName:geoFenceName];
    
    if (fences.count) {
        DNDebugLog(@"%@", geoFenceName);
        NSDictionary *fence = fences[0];
        CLLocationCoordinate2D coordinate2D = [self coordinateForGeoFence:fences[0]];
        CLLocationCoordinate2D outsidecoordinate2D = [self locationWithBearing:0
                                                                      distance:[fence[@"radiusMetres"] floatValue] + 50
                                                                  fromLocation:coordinate2D];
        [self simulateLocationUpdateAt:outsidecoordinate2D];
    }
}

- (void)simulateGeoFenceEntryWithID:(NSString*)geoFenceID;
{
    NSArray *fences = [[DGFMainController sharedInstance] allGeoFencesForGeoFenceID:geoFenceID];
    
    if (fences.count) {
        DNDebugLog(@"%@", geoFenceID);
        CLLocationCoordinate2D coordinate2D = [self coordinateForGeoFence:fences[0]];
        [self simulateLocationUpdateAt:coordinate2D];
    }
}

- (void)simulateGeoFenceExitWithID:(NSString*)geoFenceID;
{
    NSArray *fences = [[DGFMainController sharedInstance] allGeoFencesForGeoFenceID:geoFenceID];
    
    if (fences.count) {
        DNDebugLog(@"%@", geoFenceID);
        NSDictionary *fence = fences[0];
        CLLocationCoordinate2D coordinate2D = [self coordinateForGeoFence:fences[0]];
        CLLocationCoordinate2D outsidecoordinate2D = [self locationWithBearing:0
                                                                      distance:[fence[@"radiusMetres"] floatValue] + 50
                                                                  fromLocation:coordinate2D];
        [self simulateLocationUpdateAt:outsidecoordinate2D];
    }
}

- (void)simulateLocationUpdateAt:(CLLocationCoordinate2D)location2D
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:location2D.latitude longitude:location2D.longitude];
    [[DGFMainController sharedInstance] setCurrentProcessedLocation:location];
    [[DGFDwellTimer sharedInstance] markForDwellTimeCheckAtLocation:location2D];
}

- (CLLocationCoordinate2D)coordinateForGeoFence:(NSDictionary*)dictionary
{
    NSDictionary *centrePoint = dictionary[@"centrePoint"];
    CLLocationCoordinate2D coordinate2D = CLLocationCoordinate2DMake([centrePoint[@"latitude"] doubleValue],
                                                                     [centrePoint[@"longitude"] doubleValue]);
    return coordinate2D;
}

- (CLLocationCoordinate2D)locationWithBearing:(float)bearing distance:(float)distanceMeters fromLocation:(CLLocationCoordinate2D)origin {
    CLLocationCoordinate2D target;
    const double distRadians = distanceMeters / (6372797.6); // earth radius in meters
    
    float lat1 = (float) (origin.latitude * M_PI / 180);
    float lon1 = (float) (origin.longitude * M_PI / 180);
    
    float lat2 = (float) asin( sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearing));
    float lon2 = (float) (lon1 + atan2( sin(bearing) * sin(distRadians) * cos(lat1),
                                  cos(distRadians) - sin(lat1) * sin(lat2) ));
    
    target.latitude = lat2 * 180 / M_PI;
    target.longitude = lon2 * 180 / M_PI; // no need to normalize a heading in degrees to be within -179.999999° to 180.00000°
    
    return target;
}

@end
