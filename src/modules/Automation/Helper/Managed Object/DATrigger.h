//
//  DATrigger.h
//  GeoFenceModule
//
//  Created by Donky Networks on 02/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DATrigger : NSManagedObject

@property (nonatomic, retain) id actionData;
@property (nonatomic, retain) NSNumber * executionsInInterval;
@property (nonatomic, retain) NSDate * lastExecuted;
@property (nonatomic, retain) NSNumber * numberOfExecutions;
@property (nonatomic, retain) id restrictions;
@property (nonatomic, retain) id triggerData;
@property (nonatomic, retain) NSString * triggerID;
@property (nonatomic, retain) NSString * triggerType;
@property (nonatomic, retain) NSDate * validFrom;
@property (nonatomic, retain) NSDate * validTo;

@end
