//
//  DGFRegionManager.h
//  GeoFenceModule
//
//  Created by Chris Watson on 02/06/2015.
//  Copyright (c) 2015 Chris Watson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNBlockDefinitions.h"
#import "DNRegion.h"

@class DNServerNotification;

@interface DGFRegionManager : NSObject <NSFetchedResultsControllerDelegate>

@property(nonatomic, strong) NSMutableArray *geoFenceUpdateBlocks;
@property(nonatomic, strong) NSMutableArray *geoFenceCrossingBlocks;

- (instancetype)init;

- (void)insertNewRegionDefinition:(NSDictionary *)regionData context:(NSManagedObjectContext *)context serverNotification:(DNServerNotification *)serverNotification;

- (NSError *)deleteRegionDefinition:(id)data;
- (void)deleteAllRegions;

- (NSArray *)regionsOnDeviceInMemoryFormat;
+ (DNRegion*)updateTimeEntered:(NSDate*)entered forRegionID:(NSString*)regionID;
+ (DNRegion*)updateTimeLeft:(NSDate*)exited forRegionID:(NSString*)regionID;

+ (void)reportNewRegionTrackingStatus:(DNRegion *)region serverNotification:(DNServerNotification *)serverNotification;

+ (void)reportGeoFence:(DNRegion *)region serverNotification:(DNServerNotification *)serverNotification monitoringStatus:(NSString *)status wasSuccessful:(BOOL)success;

@end
