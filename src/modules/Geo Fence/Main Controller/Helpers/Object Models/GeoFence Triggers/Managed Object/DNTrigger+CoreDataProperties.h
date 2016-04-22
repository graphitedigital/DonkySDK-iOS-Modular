//
//  DNTrigger+CoreDataProperties.h
//  GeoFenceModule
//
//  Created by Donky Networks on 29/09/2015.
//  Copyright © 2015 Chris Watson. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DNTrigger.h"

NS_ASSUME_NONNULL_BEGIN

@interface DNTrigger (CoreDataProperties)

@property (nullable, nonatomic, retain) id actionData;
@property (nullable, nonatomic, retain) NSNumber *direction;
@property (nullable, nonatomic, retain) NSNumber *executionsInInterval;
@property (nullable, nonatomic, retain) NSDate *lastExecuted;
@property (nullable, nonatomic, retain) NSNumber *numberOfExecutions;
@property (nullable, nonatomic, retain) id restrictions;
@property (nullable, nonatomic, retain) NSNumber *timeInRegion;
@property (nullable, nonatomic, retain) id triggerData;
@property (nullable, nonatomic, retain) NSString *triggerId;
@property (nullable, nonatomic, retain) NSDate *validFrom;
@property (nullable, nonatomic, retain) id validity;
@property (nullable, nonatomic, retain) NSDate *validTo;
@property (nullable, nonatomic, retain) NSSet<DNRegion *> *region;

@end

@interface DNTrigger (CoreDataGeneratedAccessors)

- (void)addRegionObject:(DNRegion *)value;
- (void)removeRegionObject:(DNRegion *)value;
- (void)addRegion:(NSSet<DNRegion *> *)values;
- (void)removeRegion:(NSSet<DNRegion *> *)values;

@end

NS_ASSUME_NONNULL_END
