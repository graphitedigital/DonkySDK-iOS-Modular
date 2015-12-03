//
//  DATrigger.m
//  GeoFenceModule
//
//  Created by Donky Networks on 02/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DATrigger.h"

@implementation DATrigger

@dynamic actionData;
@dynamic executionsInInterval;
@dynamic lastExecuted;
@dynamic numberOfExecutions;
@dynamic restrictions;
@dynamic triggerData;
@dynamic triggerID;
@dynamic triggerType;
@dynamic validFrom;
@dynamic validTo;

@end
