//
//  DNNetworkDataHelper.m
//  DonkyMaster
//
//  Created by Donky Networks on 03/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import "DNSystemHelpers.h"
#import "DNContentNotification.h"
#import "NSManagedObject+DNHelper.h"
#import "NSMutableDictionary+DNDictionary.h"
#import "DNLoggingController.h"
#import "NSManagedObjectContext+DNDelete.h"
#import "DNDataController.h"
#import "DNNetworkDataHelper.h"

static const int DNMaximumSendTries = 10;

static NSString *const DNType = @"type";
static NSString *const DNCustomNotificationType = @"Custom";
static NSString *const DNDefinition = @"definition";
static NSString *const DNContent = @"content";
static NSString *const DNFilters = @"filters";
static NSString *const DNAudience = @"audience";
static NSString *const DNSendContent = @"SendContent";
static NSString *const DNAcknowledgementDetails = @"acknowledgementDetail";

@implementation DNNetworkDataHelper

+ (void)clientNotifications:(DNClientNotification *)notification insertObject:(BOOL)insert completion:(DNNetworkControllerSuccessBlock)completion {

    __block DNNotification *clientNotification = nil;
    NSManagedObjectContext *context = [DNDataController temporaryContext];
    @try {
        [context performBlockAndWait:^{
            NSManagedObjectID *objectID = [[DNNotification fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"serverNotificationID == %@ || notificationID == %@", [notification notificationID], [notification notificationID]] withContext:context includesPendingChanges:YES] objectID];
            NSError *error;
            if (objectID) {
                clientNotification = (DNNotification *) [context existingObjectWithID:objectID error:&error];
            }

            if (!clientNotification && insert) {
                clientNotification = [DNNotification insertNewInstanceWithContext:context];
                [clientNotification setServerNotificationID:[notification notificationID] ?: [DNSystemHelpers generateGUID]];
                [clientNotification setType:[notification notificationType]];
                [clientNotification setAcknowledgementDetails:[notification acknowledgementDetails]];
                [clientNotification setData:[notification data]];
            }
            
            [clientNotification setSendTries:[notification sendTries]];

            [[DNDataController sharedInstance] saveContext:context completion:^(id data) {
                if (completion) {
                    completion([clientNotification objectID]);
                }
            }];
        }];
    }

    @catch (NSException *exception) {
        DNErrorLog(@"Fatal exception (%@) when processing client notification.... Reporting & Continuing", [exception description]);
        [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil];
    }
}

+ (NSArray *)clientNotificationsWithContext:(NSManagedObjectContext *)context {
    NSArray *allNotifications = [DNNotification fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"type != %@", DNCustomNotificationType]
                                           sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:DNType ascending:YES]]
                                               withContext:context];
    return [self mappedClientNotifications:allNotifications withContext:context];
}

+ (NSArray *)mappedClientNotifications:(NSArray *)allNotifications withContext:(NSManagedObjectContext *)context {
    NSMutableArray *formattedArray = [[NSMutableArray alloc] init];
    NSMutableArray *brokenArray = [[NSMutableArray alloc] init];
    [allNotifications enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DNNotification *storeNotification = obj;
        DNClientNotification *notification = [[DNClientNotification alloc] initWithNotification:storeNotification];
        if ([storeNotification notificationID] || [storeNotification serverNotificationID]) {
            [formattedArray addObject:notification];
        }
        else {
            [brokenArray addObject:storeNotification];
        }
    }];

    if ([brokenArray count]) {
        [context deleteAllObjectsInArray:brokenArray];
        [[DNDataController sharedInstance] saveContext:context];
    }

    return formattedArray;
}

+ (void)contentNotifications:(DNContentNotification *)notification insertObject:(BOOL)insert completion:(DNNetworkControllerSuccessBlock)completion {

    NSManagedObjectContext * context = nil;
    if ([[NSThread currentThread] isMainThread]) {
        context = [[DNDataController sharedInstance] mainContext];
    }
    else {
        context = [DNDataController temporaryContext];
    }

    //Check if we already have a client notification for this id:
    __block DNNotification *contentNotification = nil;

    [context performBlockAndWait:^{

        contentNotification = [DNNotification fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"notificationID == %@ || serverNotificationID == %@", [notification notificationID], [notification notificationID]]
                                                                 withContext:context
                                                      includesPendingChanges:NO];

        if (!contentNotification && insert) {
            contentNotification = [DNNotification insertNewInstanceWithContext:context];
            [contentNotification setServerNotificationID:[notification notificationID] ?: [DNSystemHelpers generateGUID]];
            [contentNotification setType:DNCustomNotificationType];
            [contentNotification setData:(id) [notification acknowledgementDetails]];
            [contentNotification setAudience:[notification audience]];
            [contentNotification setContent:[notification content]];
            [contentNotification setFilters:[notification filters]];
            [contentNotification setNativePush:[notification nativePush]];
        }
        
        [contentNotification setSendTries:[notification sendTries]];
        
        [[DNDataController sharedInstance] saveContext:context];

        if (completion) {
            completion([contentNotification objectID]);
        }
    }];
}

+ (NSArray *)contentNotificationsWithContext:(NSManagedObjectContext *)context {
    NSArray *allNotifications = [DNNotification fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"type == %@", DNCustomNotificationType]
                                                          sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:DNType ascending:YES]]
                                                              withContext:context];
    return [self mappedContentNotification:allNotifications withTemp:context];
}

+ (NSArray *)mappedContentNotification:(NSArray *)allNotifications withTemp:(NSManagedObjectContext *)context {
    NSMutableArray *formattedArray = [[NSMutableArray alloc] init];
    NSMutableArray *brokenArray = [[NSMutableArray alloc] init];
    [allNotifications enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DNNotification *storeNotification = obj;
        DNContentNotification *notification = [[DNContentNotification alloc] initWithAudience:[storeNotification audience]
                                                                                      filters:[storeNotification filters]
                                                                                      content:[storeNotification content]
                                                                                   nativePush:[storeNotification nativePush]];
        if ([storeNotification notificationID] || [storeNotification serverNotificationID]) {
            [formattedArray addObject:notification];
        }
        else {
            [brokenArray addObject:storeNotification];
        }
    }];

    if ([brokenArray count]) {
        [context deleteAllObjectsInArray:brokenArray];
        [[DNDataController sharedInstance] saveContext:context];
    }

    return formattedArray;
}

+ (NSMutableDictionary *)networkClientNotifications:(NSMutableArray *)clientNotifications networkContentNotifications:(NSMutableArray *)contentNotifications tempContext:(BOOL)temp {
    DNInfoLog(@"Preparing Notifications for network");
    __block NSMutableArray *allNotifications = [[NSMutableArray alloc] init];
    __block NSMutableArray *brokenNotifications = [[NSMutableArray alloc] init];

    [clientNotifications enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[DNClientNotification class]]) {
            DNErrorLog(@"WHoops, something has gone wrong with this client notification. Expected class DNClientNotification, got: %@", NSStringFromClass([obj class]));
        }
        else {
            DNClientNotification *originalNotification = obj;

            NSInteger sendTries = [[originalNotification sendTries] integerValue];
            sendTries ++;
            [originalNotification setSendTries:@(sendTries)];

            NSMutableDictionary *formattedNotification = [[NSMutableDictionary alloc] init];
            [formattedNotification dnSetObject:[originalNotification notificationType] forKey:DNType];

            if ([originalNotification acknowledgementDetails]) {
                [formattedNotification dnSetObject:[originalNotification acknowledgementDetails] forKey:DNAcknowledgementDetails];
            }

            [[originalNotification data] enumerateKeysAndObjectsUsingBlock:^(id key, id obj2, BOOL *stop2) {
                [formattedNotification dnSetObject:obj2 forKey:key];
            }];

            if (![self checkForBrokenNotification:formattedNotification] && [originalNotification notificationID]) {
                [allNotifications addObject:formattedNotification];
            }
            else {
                [brokenNotifications addObject:originalNotification];
            }
        }
    }];

    __block NSManagedObjectContext * context = nil;
    if ([[NSThread currentThread] isMainThread]) {
        context = [[DNDataController sharedInstance] mainContext];
    }
    else {
        context = [DNDataController temporaryContext];
    }
    
    if ([brokenNotifications count]) {
        [context performBlock:^{
            [brokenNotifications enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DNClientNotification *brokenClient = obj;
                [self clientNotifications:brokenClient insertObject:NO completion:^(id data) {
                    NSManagedObjectID *brokenID = data;
                    if (brokenID) {
                        [context deleteObject:[context existingObjectWithID:brokenID error:nil]];
                    }
                }];
            }];
            [[DNDataController sharedInstance] saveContext:context];
        }];
        
        [brokenNotifications removeAllObjects];
    }
    
    [contentNotifications enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[DNContentNotification class]]) {
            DNErrorLog(@"WHoops, something has gone wrong with this client notification. Expected class DNContentNotification, got: %@", NSStringFromClass([obj class]));
        }
        else {
            DNContentNotification *originalNotification = obj;
            NSInteger sendTries = [[originalNotification sendTries] integerValue];
            sendTries ++;
            [originalNotification setSendTries:@(sendTries)];
            NSMutableDictionary *formattedNotification = [[NSMutableDictionary alloc] init];
            [formattedNotification dnSetObject:DNSendContent forKey:DNType];
            NSMutableDictionary *definition = [[NSMutableDictionary alloc] init];
            [definition dnSetObject:[originalNotification audience] forKey:DNAudience];
            [definition dnSetObject:[originalNotification filters] forKey:DNFilters];
            [definition dnSetObject:[originalNotification content] forKey:DNContent];
            [formattedNotification dnSetObject:definition forKey:DNDefinition];

            if (![self checkForBrokenNotification:formattedNotification]) {
                [allNotifications addObject:formattedNotification];
            }
            else {
                [brokenNotifications addObject:originalNotification];
            }
        }
    }];

    if ([brokenNotifications count]) {
        [context performBlock:^{
            [brokenNotifications enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DNContentNotification *brokenContent = obj;
               [self contentNotifications:brokenContent insertObject:NO completion:^(id data) {
                   NSManagedObjectID *brokenID = data;
                   if (brokenID) {
                       [context deleteObject:[context existingObjectWithID:brokenID error:nil]];
                   }
               }];
            }];

            [[DNDataController sharedInstance] saveContext:context];
        }];
    }

    //Prepare return:
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params dnSetObject:allNotifications forKey:@"clientNotifications"];
    [params dnSetObject:[[UIApplication sharedApplication] applicationState] != UIApplicationStateActive ? @"true" : @"false" forKey:@"isBackground"];


    return params;
}

+ (BOOL)checkForBrokenNotification:(NSMutableDictionary *)dictionary {
    //Do we have a type:
    NSString *type = dictionary[DNType];
    return !type;
}

+ (void)saveClientNotificationsToStore:(NSArray *)array {
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[DNClientNotification class]]) {
            DNErrorLog(@"WHoops, something has gone wrong with this client notification. Expected class DNClientNotification, got: %@", NSStringFromClass([obj class]));
        }
        else {
            DNClientNotification *clientNotification = obj;
            [self clientNotifications:clientNotification insertObject:YES completion:nil];
        }
    }];
}

+ (NSMutableArray *)sendContentNotifications:(NSArray *)notifications withContext:(NSManagedObjectContext *)context {

    __block NSMutableArray *allNotifications = [[NSMutableArray alloc] init];
    __block NSMutableArray *brokenNotifications = [[NSMutableArray alloc] init];

    [notifications enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[DNContentNotification class]]) {
            DNErrorLog(@"Whoops, something has gone wrong with this client notification. Expected class DNContentNotification, got: %@", NSStringFromClass([obj class]));
        }
        else {
            DNContentNotification *originalNotification = obj;
            NSInteger sendTries = [[originalNotification sendTries] integerValue];
            sendTries++;
            [originalNotification setSendTries:@(sendTries)];
            NSMutableDictionary *formattedNotification = [[NSMutableDictionary alloc] init];
            [formattedNotification dnSetObject:[originalNotification audience] forKey:DNAudience];
            [formattedNotification dnSetObject:[originalNotification filters] forKey:DNFilters];
            [formattedNotification dnSetObject:[originalNotification content] forKey:DNContent];
            [allNotifications addObject:formattedNotification];
        }
    }];

    [self deleteNotifications:brokenNotifications];

    return allNotifications;
}

+ (void)saveContentNotificationsToStore:(NSArray *)array {
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[DNContentNotification class]]) {
            DNErrorLog(@"WHoops, something has gone wrong with this client notification. Expected class DNContentNotification, got: %@", NSStringFromClass([obj class]));
        }
        else {
            DNContentNotification *contentNotification = obj;
            [self contentNotifications:contentNotification insertObject:YES completion:nil];
        }
    }];
}

+ (void)deleteNotifications:(NSArray *)notifications {
    __block DNNotification *notification = nil;
    __block NSManagedObjectContext * context = nil;
    if ([[NSThread currentThread] isMainThread]) {
        context = [[DNDataController sharedInstance] mainContext];
    }
    else {
        context = [DNDataController temporaryContext];
    }

    __block NSMutableArray *notificationsToDelete = [[NSMutableArray alloc] init];
    [context performBlockAndWait:^{
        [notifications enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            DNClientNotification *clientNotification = obj;
            if ([obj isKindOfClass:[DNClientNotification class]]) {
                NSManagedObjectID *objectID = [DNNetworkDataHelper notificationWithID:[clientNotification notificationID] context:context];
                if (objectID) {
                    notification = (DNNotification *) [context existingObjectWithID:objectID error:nil];
                }
            }
            else {
               NSManagedObjectID *objectID = [DNNetworkDataHelper notificationWithID:[clientNotification notificationID] context:context];
               if (objectID) {
                   notification = (DNNotification *) [context existingObjectWithID:objectID error:nil];
               }
            }

            if (notification) {
                [notificationsToDelete addObject:notification];
            }
        }];

        [context deleteAllObjectsInArray:notificationsToDelete];
        [[DNDataController sharedInstance] saveContext:context];
    }];
}

+ (void)clearBrokenNotifications {
    __block NSManagedObjectContext * context = nil;
    if ([[NSThread currentThread] isMainThread]) {
        context = [[DNDataController sharedInstance] mainContext];
    }
    else {
        context = [DNDataController temporaryContext];
    }
    [context performBlock:^{
        //Get all broken types i.e. send tries > 10 && with no valid type:
        NSArray *brokenDonkyNotifications = [DNNotification fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"sendTries >= %d", DNMaximumSendTries]
                                                                      sortDescriptors:nil
                                                                          withContext:context];
        if (![brokenDonkyNotifications count]) {
            return;
        }

        [context deleteAllObjectsInArray:brokenDonkyNotifications];
        [[DNDataController sharedInstance] saveContext:context];
    }];
}

+ (void)deleteNotificationForID:(NSString *)serverID {
    __block NSManagedObjectContext * context = nil;
    if ([[NSThread currentThread] isMainThread]) {
        context = [[DNDataController sharedInstance] mainContext];
    }
    else {
        context = [DNDataController temporaryContext];
    }
    [context performBlock:^{
        DNNotification *clientNotification = [DNNotification fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"serverNotificationID == %@", serverID]
                                                                                withContext:context
                                                                     includesPendingChanges:NO];
        if (clientNotification) {
            [context deleteObject:clientNotification];
            [[DNDataController sharedInstance] saveContext:context];
        }
    }];
}

+ (NSManagedObjectID *)notificationWithID:(NSString *)notificationID context:(NSManagedObjectContext *)context {
    if (!notificationID) {
        DNErrorLog(@"Cannot look for notificaiotns without an ID");
    }
    return [[DNNotification fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"serverNotificationID == %@ || notificationID == %@", notificationID, notificationID]
                                               withContext:context
                                    includesPendingChanges:YES] objectID];
}

@end
