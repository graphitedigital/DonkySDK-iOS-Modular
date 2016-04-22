//
//  DNRegion+CoreDataProperties.h
//  GeoFenceModule
//
//  Created by Donky Networks on 23/09/2015.
//  Copyright © 2015 Chris Watson. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DNRegion.h"
#import "DNTrigger.h"

NS_ASSUME_NONNULL_BEGIN

@interface DNRegion (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *activationid;
@property (nullable, nonatomic, retain) NSDate *activatedOn;
@property (nullable, nonatomic, retain) NSString *applicationId;
@property (nullable, nonatomic, retain) NSDate *timeEntered;
@property (nullable, nonatomic, retain) id labels;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *notificationId;
@property (nullable, nonatomic, retain) NSDate *processedOn;
@property (nullable, nonatomic, retain) NSSet <DNTrigger*> *relatedTriggers;
@property (nullable, nonatomic, retain) NSNumber *status;
@property (nullable, nonatomic, retain) NSDate *timeLeft;
@property (nullable, nonatomic, retain) NSNumber *radiusMetres;
@property (nullable, nonatomic, retain) NSNumber *trackingReported;
@property (nullable, nonatomic, retain) NSString *triggerId;
@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSString *regionID;
@property (nullable, nonatomic, retain) NSSet <DNTrigger*> *triggers;

@end

@interface DNRegion (CoreDataGeneratedAccessors)

- (void)addTriggersObject:(NSManagedObject *)value;
- (void)removeTriggersObject:(NSManagedObject *)value;
- (void)addTriggers:(NSSet<NSManagedObject *> *)values;
- (void)removeTriggers:(NSSet<NSManagedObject *> *)values;

@end

NS_ASSUME_NONNULL_END
