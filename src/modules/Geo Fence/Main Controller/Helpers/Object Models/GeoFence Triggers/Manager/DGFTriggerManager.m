//
//  DGFTriggerManager.m
//  GeoFenceModule
//
//  Created by Donky Networks Ltd on 02/06/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DGFTriggerManager.h"
#import "DNDataController.h"
#import "NSDate+DNDateHelper.h"
#import "NSManagedObject+DNHelper.h"
#import "NSManagedObjectContext+DNDelete.h"
#import "DNLoggingController.h"

static NSString *const DGFTriggerSortDescriptor = @"triggerID";

@interface DGFTriggerManager ()
@property(nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

#pragma mark - OBJECT creation

@implementation DGFTriggerManager

- (instancetype) init {
    
    self = [super init];
    
    if (self) {
        self.triggerUpdateBlocks = [[NSMutableArray alloc] init];
        self.triggerFiredBlocks = [[NSMutableArray alloc] init];
    }

    return self;
}

#pragma mark - INSERT / DELETE

- (NSManagedObjectID *)insertNewTriggerDefinition:(NSDictionary *) triggerData {
    
    if (!triggerData)
    {
        return nil;
    }
    
    NSManagedObjectContext *temporaryContext = [DNDataController temporaryContext];

    __block DNTrigger *trigger = [DNTrigger fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"triggerId == %@", triggerData[@"triggerId"]] withContext:temporaryContext includesPendingChanges:NO];

    [temporaryContext performBlockAndWait:^{
        if (!trigger) {
            trigger = [DNTrigger insertNewInstanceWithContext:temporaryContext];
        }
        
        [trigger setActionData:triggerData[@"actionData"]];
        
        NSInteger direction = DGFTriggerRegionDirectionBoth;
        NSString *triggerDirection = triggerData[@"triggerData"][@"direction"];
        if ([triggerDirection isEqualToString:@"EnteringRegion"]) {
            direction = DGFTriggerRegionDirectionIn;
        }
        if ([triggerDirection isEqualToString:@"LeavingRegion"]) {
            direction = DGFTriggerRegionDirectionOut;
        }

        [trigger setDirection:[NSNumber numberWithInteger:direction]];
        [trigger setExecutionsInInterval:triggerData[@"executionsInInterval"]];
        [trigger setLastExecuted:[NSDate donkyDateFromServer:triggerData[@"lastExecuted"]]];
        [trigger setNumberOfExecutions:triggerData[@"numberOfExecutions"]];
        [trigger setTimeInRegion:triggerData[@"triggerData"][@"timeInRegionSeconds"]];
        
        [trigger setRestrictions:triggerData[@"restrictions"]];
        [trigger setTriggerData:triggerData[@"triggerData"]];
        [trigger setTriggerId:triggerData[@"triggerId"]];
        
        [trigger setValidity:triggerData[@"validity"]];
        NSString *validFrom = triggerData[@"validity"][@"validFrom"];
        NSString *validTo = triggerData[@"validity"][@"validTo"];
        [trigger setValidFrom:[NSDate donkyDateFromServer:validFrom]];
        [trigger setValidTo:[NSDate donkyDateFromServer:validTo]];
                
        [[DNDataController sharedInstance] saveContext:temporaryContext];
        
        //Do we have a ALL completion block request?
        if ([[self triggerUpdateBlocks] count]) {
            [[self triggerUpdateBlocks] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                DGFTriggerUpdateBlock triggerBlock = obj;
                triggerBlock(triggerData);
            }];
        }
    }];
    
    return [trigger objectID];
}

// remove all current Triggers
- (void)deleteAllTriggers {
    
    NSManagedObjectContext *context = [DNDataController temporaryContext];
    
    [context performBlockAndWait:^{
        NSArray *allObjects = [DNTrigger fetchObjectsWithOffset:0
                                                         limit:NSIntegerMax
                                                sortDescriptor:nil
                                                   withContext:context];
        
        [context deleteAllObjectsInArray:allObjects];
        [[DNDataController sharedInstance] saveContext:context];
    }];
}

- (NSError *)deleteTriggerDefinition:(id)data {

    return nil;
}

#pragma mark - Fetch Results Controller

-(NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController == nil) {

        NSFetchRequest *request = [DNTrigger fetchRequestWithContext:[[DNDataController sharedInstance] mainContext]];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:DGFTriggerSortDescriptor ascending:YES]];

        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:[[DNDataController sharedInstance] mainContext]
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
        [_fetchedResultsController setDelegate:self];

        NSError *error;
        if (![_fetchedResultsController performFetch:&error]) {
            DNDebugLog(@"Problem fetching comments for request: %@\nError: %@", request, error);
        }
    }

    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{

}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            break;

        case NSFetchedResultsChangeDelete:
            break;
        case NSFetchedResultsChangeMove:break;
        case NSFetchedResultsChangeUpdate:break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {

        case NSFetchedResultsChangeInsert:

            break;

        case NSFetchedResultsChangeDelete:

            break;

        case NSFetchedResultsChangeUpdate:
            break;

        case NSFetchedResultsChangeMove:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{

}

#pragma mark - HELPERS

+ (BOOL)canProceed:(DNTrigger *)trigger withDirection:(DGFTriggerRegionDirection)direction {
    
    NSDictionary *triggerRestrictions = [trigger restrictions];
    
    //Check Direction:
    if (triggerRestrictions && [trigger direction] && ([[trigger direction] intValue] != direction && [[trigger direction] intValue] != DGFTriggerRegionDirectionBoth))
        return NO;
    
    //If we have no restrictions:
    if((!triggerRestrictions) || (!triggerRestrictions.count))
        return YES;
    
    //If we have date restrictions:
    if (trigger.validFrom)
        if (![trigger.validFrom donkyHasDateExpired])
            return NO;
    
    if (trigger.validFrom && trigger.validTo) {
        if ([[trigger validTo] donkyHasDateExpired] || ![[trigger validFrom] donkyHasReachedDate])
        return NO;
    }
    
    NSInteger maximumExecutions = [triggerRestrictions[@"MaximumExecutions"] integerValue];
    
    //If we are at the maximum total:
    if ([trigger.numberOfExecutions integerValue] >= maximumExecutions && maximumExecutions != 0)
        return NO;
    
    NSInteger maximumExecutionsPerInterval = [triggerRestrictions[@"MaximumExecutionsPerInterval"] integerValue];
    
    //Create a total time interval in seconds:
    NSTimeInterval secondsInInterval =  [triggerRestrictions[@"MaximumExecutionsIntervalSeconds"] integerValue];
    
    //Time since last execution:
    NSTimeInterval timeSinceLastExecution = trigger.lastExecuted ? [[NSDate date] timeIntervalSinceDate:trigger.lastExecuted] : 0.0;
    
    NSInteger executionsInTimeInterval = [trigger.executionsInInterval integerValue];
    
    //Are we in inside the interval:
    if (timeSinceLastExecution < secondsInInterval) {
        //If we are at the maximum in the time interval:
        if (executionsInTimeInterval >= maximumExecutionsPerInterval)
            return NO;
    }
    
    //We are outside of the time interval, so reset the count:
    else {
        executionsInTimeInterval = 0;
        trigger.lastExecuted = nil;
    }
    
    //We only set the date for the first execution and then when we are outside of the time interval:
    if (!trigger.lastExecuted)
        trigger.lastExecuted = [NSDate date];
    
    NSInteger numberOfExecutions = [trigger.numberOfExecutions integerValue] + 1;
    
    trigger.numberOfExecutions = @(numberOfExecutions);
    trigger.executionsInInterval = @(executionsInTimeInterval + 1);
    
    return YES;
}

@end
