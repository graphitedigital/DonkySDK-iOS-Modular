//
//  DGFTriggerManager.h
//  GeoFenceModule
//
//  Created by Chris Watson on 02/06/2015.
//  Copyright (c) 2015 Chris Watson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DGFConstants.h"
#import "DNTrigger.h"

@interface DGFTriggerManager : NSObject <NSFetchedResultsControllerDelegate>

@property(nonatomic, strong) NSMutableArray *triggerUpdateBlocks;
@property(nonatomic, strong) NSMutableArray *triggerFiredBlocks;

- (instancetype)init;

- (NSError *)insertNewTriggerDefinition:(NSDictionary *)triggerData;
- (void)deleteAllTriggers;
- (NSError *)deleteTriggerDefinition:(id)data;

+ (BOOL)canProceed:(DNTrigger *)trigger withDirection:(DGFTriggerRegionDirection)direction;

@end
