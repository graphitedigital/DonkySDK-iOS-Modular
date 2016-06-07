//
//  DGFRegionManager.m
//  GeoFenceModule
//
//  Created by Donky Networks Ltd on 02/06/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import <CoreLocation/CoreLocation.h>

#import "NSMutableDictionary+DNDictionary.h"
#import "NSManagedObjectContext+DNHelpers.h"
#import "NSManagedObjectContext+DNDelete.h"
#import "NSManagedObject+DNHelper.h"
#import "NSDate+DNDateHelper.h"
#import "DNLoggingController.h"
#import "DGFRegionManager.h"
#import "DNDataController.h"
#import "DGFConstants.h"
#import "DNClientNotification.h"
#import "DNNetworkController.h"

static NSString *const DGFRegionSortDescriptor = @"regionID";

@interface DGFRegionManager ()
@end

@implementation DGFRegionManager

- (instancetype)init {

    self = [super init];

    if (self) {
        // update blocks
        self.geoFenceUpdateBlocks = [[NSMutableArray alloc] init];
        // crossing blocks
        self.geoFenceCrossingBlocks = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)insertNewRegionDefinition:(NSDictionary *)regionData context:(NSManagedObjectContext *)context serverNotification:(DNServerNotification *)serverNotification {
    if (!regionData) {
        return;
    }
    
    [context performBlock:^{
        DNRegion *region = [DNRegion fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"regionID == %@", regionData[@"id"]]
                                                        withContext:context
                                             includesPendingChanges:NO];
        
        if (!region) {
            region = [DNRegion insertNewInstanceWithContext:context];
        }
        
        DNInfoLog(@"Region : %@", regionData[@"name"]);
        [region setActivatedOn:[NSDate donkyDateFromServer:regionData[@"activatedOn"]]];
        [region setActivationid:regionData[@"activationId"]];
        [region setApplicationId:regionData[@"applicationId"]];
        [region setTimeEntered:[NSDate donkyDateFromServer:regionData[@"timeEntered"]]];
        [region setLabels:regionData[@"labels"]];
        
        NSDictionary *centerPoint = regionData[@"centrePoint"];
        [region setLatitude:centerPoint[@"latitude"]];
        [region setLongitude:centerPoint[@"longitude"]];
        
        [region setName:regionData[@"name"]];
        [region setProcessedOn:[NSDate donkyDateFromServer:regionData[@"processedOn"]]];
        [region setRelatedTriggers:regionData[@"relatedTriggers"]];
        [region setStatus:@([regionData[@"status"] isEqualToString:@"Active"])];
        [region setTimeLeft:[NSDate donkyDateFromServer:regionData[@"timeLeft"]]];
        [region setRadiusMetres:regionData[@"radiusMetres"]];
        [region setTrackingReported:regionData[@"trackingReported"]];
        [region setTriggerId:regionData[@"triggerId"]];
        [region setType:regionData[@"type"]];
        [region setRegionID:regionData[@"id"]];
        
        // update tracking status
        //Do we have a ALL completion block request?
        if ([[self geoFenceUpdateBlocks] count]) {
            [[self geoFenceUpdateBlocks] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                DGFGeoFenceUpdateBlock locationBlock = obj;
                locationBlock(regionData);
            }];
        }

        [[DNDataController sharedInstance] saveContext:context completion:^(id data) {
            [DGFRegionManager reportNewRegionTrackingStatus:region serverNotification:serverNotification];
        }];
    }];
}

#pragma mark - Region Monitoring Reporting

+ (void)reportNewRegionTrackingStatus:(DNRegion *)region serverNotification:(DNServerNotification *)serverNotification {
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // for monitoringDidFailForRegion
    //[self reportGeoFence:regionEntity monitoringStatus:@"LimitExceeded" wasSuccessful:NO];
    
    // for didStartMonitoringForRegion
    [DGFRegionManager reportGeoFence:region serverNotification:serverNotification monitoringStatus:nil wasSuccessful:status != kCLAuthorizationStatusDenied];
    
    // for region notification
    //[self reportGeoFence:regionEntity monitoringStatus:nil wasSuccessful:[CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied];
}

+ (void)reportGeoFence:(DNRegion *)region serverNotification:(DNServerNotification *)serverNotification monitoringStatus:(NSString *)status wasSuccessful:(BOOL)success {

    DNInfoLog(@"Reporting STARTTRACKED: %@", region.regionID);

    NSManagedObjectContext *temporaryContext = [DNDataController temporaryContext];
    [temporaryContext performBlock:^{

        DNRegion *regionCopy = [temporaryContext objectWithID:[region objectID]];

        if (regionCopy) {
            //Create notification:
            NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];

            [payload dnSetObject:[regionCopy regionID] forKey:@"Id"];
            [payload dnSetObject:[regionCopy activationid] forKey:@"ActivationId"];
            [payload dnSetObject:[[NSDate date] donkyDateForServer] forKey:@"ActivatedOn"];
            [payload dnSetObject:[[NSDate date] donkyDateForServer] forKey:@"ProcessedOn"];

            [payload dnSetObject:success ? @"true" : @"false" forKey:@"Success"];
            if (!success) {
                NSString *failure = status ?: @"NoPermission";
                [payload dnSetObject:@[failure] forKey:@"FailureReasons"];
            }

            [regionCopy setTrackingReported:@(YES)];

            if (![[regionCopy activationid] isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
                [[DNDataController sharedInstance] saveContext:temporaryContext completion:^(id data) {
                    DNClientNotification *regionMonitoring = [[DNClientNotification alloc] initWithType:@"GeoFenceDeploymentStatus" data:payload acknowledgementData:serverNotification];
                    if (serverNotification) {
                        [[regionMonitoring acknowledgementDetails] dnSetObject:@"delivered" forKey:@"result"];
                    }
                    [[DNNetworkController sharedInstance] queueClientNotifications:@[regionMonitoring]];
                }];
            }
        }
    }];
}

#pragma mark - Delete Regions

// remove all current Regions
- (void)deleteAllRegions {
    
    NSManagedObjectContext *context = [DNDataController temporaryContext];
    
    [context performBlockAndWait:^{
        NSArray *allObjects = [DNRegion fetchObjectsWithOffset:0
                                                         limit:NSIntegerMax
                                                sortDescriptor:nil
                                                   withContext:context];
        
        [context deleteAllObjectsInArray:allObjects];
        [[DNDataController sharedInstance] saveContext:context];
    }];
}

- (NSError *)deleteRegionDefinition:(id)data {

    if (!data)
    {
        return nil;
    }
    
    NSManagedObjectContext *temporaryContext = [DNDataController temporaryContext];

    [temporaryContext performBlockAndWait:^{
        DNRegion *region = [DNRegion fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"regionID == %@", data[@"id"]] withContext:temporaryContext includesPendingChanges:NO];

        if (region) {
            [temporaryContext deleteObject:region];
            [[DNDataController sharedInstance] saveContext:temporaryContext];
            
            //Do we have a ALL completion block request?
            if ([[self geoFenceUpdateBlocks] count]) {
                [[self geoFenceUpdateBlocks] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    DGFGeoFenceUpdateBlock locationBlock = obj;
                    locationBlock(data);
                }];
            }
        }
    }];
    return nil;
}

#pragma mark - InMemory Geofence State

- (NSArray*)regionsOnDeviceInMemoryFormat
{    
    NSMutableArray *returnedRegions = [[NSMutableArray alloc] init];
    NSManagedObjectContext *temporaryContext = [DNDataController temporaryContext];
    NSArray *regions = [DNRegion fetchObjectsWithPredicate:[NSPredicate predicateWithValue:YES] sortDescriptors:nil withContext:temporaryContext];
    
    // create inMemory
    for (DNRegion *region in regions) {
        
        DNDebugLog(@"Getting region from device = %@ : %@",region.regionID,region.name);
        if (region.name) {
            NSMutableDictionary *regionDict = [[NSMutableDictionary alloc] init];

            [regionDict dnSetObject:region.regionID forKey:@"id"];
            [regionDict dnSetObject:region.name forKey:@"name"];
            [regionDict dnSetObject:region.radiusMetres forKey:@"radiusMetres"];
            [regionDict dnSetObject:@{@"longitude":region.longitude,
                                    @"latitude":region.latitude} forKey:@"centrePoint"];
            [regionDict dnSetObject:region.status forKey:@"status"];
            
            if (region.timeEntered) {
                [regionDict dnSetObject:region.timeEntered forKey:@"timeEntered"];
            }
            [returnedRegions addObject:regionDict];
        }
    }

    return [NSArray arrayWithArray:returnedRegions];
}

#pragma mark - Update Time ENTERED / EXITED

+ (DNRegion*)updateTimeEntered:(NSDate*)entered forRegionID:(NSString*)regionID
{
    NSManagedObjectContext *temporaryContext = [DNDataController temporaryContext];
    __block DNRegion *region = [DNRegion fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"regionID == %@", regionID] withContext:temporaryContext includesPendingChanges:NO];
    if (region) {
        [region setTimeEntered:entered];
        [[DNDataController sharedInstance] saveContext:temporaryContext];
    }
    return region;
}

+ (DNRegion*)updateTimeLeft:(NSDate*)exited forRegionID:(NSString*)regionID
{
    NSManagedObjectContext *temporaryContext = [DNDataController temporaryContext];
    __block DNRegion *region = [DNRegion fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"regionID == %@", regionID] withContext:temporaryContext includesPendingChanges:NO];
    if (region) {
        [region setTimeLeft:exited];
        [[DNDataController sharedInstance] saveContext:temporaryContext];
    }

    return region;
}

@end
