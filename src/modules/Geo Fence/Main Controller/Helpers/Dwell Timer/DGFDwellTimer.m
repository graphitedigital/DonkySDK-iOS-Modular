//
//  DGFDwellTime.m
//  GeoFenceModule
//
//  Created by Donky Networks on 29/10/2015.
//  Copyright © 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DGFDwellTimer.h"
#import "DGFHelper.h"
#import "DNNetworkController.h"

@interface DGFDwellTimer ()
@property(nonatomic) NSInteger dwellTimeSeconds;
@property(nonatomic, strong) NSTimer *geofenceDwellTimer;
@end

@implementation DGFDwellTimer

+ (DGFDwellTimer *)sharedInstance
{
    static DGFDwellTimer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DGFDwellTimer alloc] initPrivate];
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
        // dwell time ... ensure that we have been in / out before registering ENTRY / EXIT
        [self.geofenceDwellTimer invalidate];
        self.geofenceDwellTimer = nil;
    }
    
    return  self;
}

#pragma mark - DwellTimes

- (void)markForDwellTimeCheckAtCurrentLocation
{
    if ([[DGFMainController sharedInstance] currentProcessedLocation]) {
        // sort them first
        [[DGFLocationHandler sharedInstance] sortGeofencesInMemoryFromCurrentLocation];
        [self markForDwellTimeCheckAtLocation:[[DGFMainController sharedInstance] currentProcessedLocation].coordinate];
    }
}

- (void)markForDwellTimeCheckAtLocation:(CLLocationCoordinate2D)location
{
    // must be tracking
    if (!self.isTrackingGeoFences) {
        return;
    }
    
    __block BOOL stateChanged = NO;
    
    NSArray *changesInMem = [[[DGFMainController sharedInstance] regionsInMemory] copy];
    
    [changesInMem enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // distance from centre
        NSMutableDictionary *regionInMemory = obj;
        
        NSDictionary *centrePointDict = regionInMemory[@"centrePoint"];
        
        if (centrePointDict) {
            
            CLLocationDistance distance = [DGFHelper calculateDistanceToCentre:regionInMemory[@"centrePoint"] fromLocation:location];
            NSInteger radiusMetres = [regionInMemory[@"radiusMetres"] integerValue];
            
            // CLCircularRegion *region;
            // BOOL inside = [region containsCoordinate:centre];
            // NSString *regionID = regionInMemory[@"id"];
            
            // Calculate EXITS and ENTRIES
            if (radiusMetres) {
                
                // ENTRY = we are in the fence
                if (radiusMetres > distance) {
                    
                    if ([regionInMemory valueForKey:@"timeEntered"] == nil) {
                        [regionInMemory setValue:[NSDate date] forKey:@"dwellEntryDate"];
                        stateChanged = YES;
                    }
                }
                // EXITing ? = are we EXITING the fence
                else
                {
                    // not exiting if never entered
                    if ([regionInMemory valueForKey:@"timeEntered"] != nil) {
                        [regionInMemory setValue:[NSDate date] forKey:@"dwellExitDate"];
                        stateChanged = YES;
                    }
                }
            }
        }
    }];
    
    if (!stateChanged)
    {
        return;
    }
    
    // set timer
    NSTimeInterval dwelltime = [self dwellTimeSeconds];
    if (!dwelltime) {
        dwelltime = kDGFDefaultDwellTimeIfNotSetSeconds;
    }
    
    [self.geofenceDwellTimer invalidate];
    self.geofenceDwellTimer = [NSTimer scheduledTimerWithTimeInterval:dwelltime
                                                               target:self
                                                             selector:@selector(checkDwelltimes)
                                                             userInfo:nil
                                                              repeats:NO];
}

- (void)checkDwelltimes
{
    if (![[DGFMainController sharedInstance] currentProcessedLocation]) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        for (NSMutableDictionary *regionInMemory in [[DGFMainController sharedInstance] regionsInMemory]) {
            
            // distance from centre
            NSDictionary *centrePointDict = regionInMemory[@"centrePoint"];
            
            if (centrePointDict) {
                
                CLLocationDistance distance = [DGFHelper calculateDistanceToCentre:regionInMemory[@"centrePoint"] fromLocation:[DGFMainController sharedInstance].currentProcessedLocation.coordinate];
                NSInteger radiusMetres = [regionInMemory[@"radiusMetres"] integerValue];
                
                // (NOTE) Another mechnism for determining inside =
                // CLCircularRegion *region;
                // BOOL inside = [region containsCoordinate:centre];
                NSString *regionID = regionInMemory[@"id"];
                
                // Calculate EXITS as well has ENTRIES
                if (radiusMetres) {
                    
                    // ENTRY = we are in the fence
                    if (radiusMetres > distance) {
                        if ((regionInMemory[@"dwellEntryDate"]) && ([regionInMemory valueForKey:@"timeEntered"] == nil)) {
                            [regionInMemory removeObjectForKey:@"dwellEntryDate"];
                            [regionInMemory setValue:[NSDate date] forKey:@"timeEntered"];
                            
                            // update main controller with ENTRY
                            [[DGFMainController sharedInstance] fenceCrossingForRegionID:regionID inDirection:DGFTriggerRegionDirectionIn timeInRegion:0];
                        }
                    }
                    // EXIT = are we EXITING the fence
                    else
                    {
                        if ((regionInMemory[@"dwellExitDate"]) && ([regionInMemory valueForKey:@"timeEntered"] != nil)) {
                            
                            NSDate *timeEntered = regionInMemory[@"timeEntered"];
                            NSTimeInterval timeInRegion = [[NSDate date] timeIntervalSinceDate:timeEntered];
                            [regionInMemory removeObjectForKey:@"dwellExitDate"];
                            [regionInMemory removeObjectForKey:@"timeEntered"];
                            [regionInMemory setValue:[NSDate date] forKey:@"timeLeft"];
                            
                            // update main controller with EXIT
                            [[DGFMainController sharedInstance] fenceCrossingForRegionID:regionID inDirection:DGFTriggerRegionDirectionOut timeInRegion:timeInRegion];
                        }
                    }
                }
            }
        }
        // Sync
        [[DNNetworkController sharedInstance] synchronise];
    });
}

@end
