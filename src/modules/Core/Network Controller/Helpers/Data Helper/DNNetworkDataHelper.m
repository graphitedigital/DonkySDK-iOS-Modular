//
//  DNNetworkDataHelper.m
//  DonkyMaster
//
//  Created by Chris Watson on 03/06/2015.
//  Copyright (c) 2015 Chris Watson. All rights reserved.
//

#import "DNSystemHelpers.h"
#import "DNContentNotification.h"
#import "NSManagedObject+DNHelper.h"
#import "NSMutableDictionary+DNDictionary.h"
#import "DNLoggingController.h"
#import "NSManagedObjectContext+DNDelete.h"
#import "DNDataController.h"
#import "DNNetworkDataHelper.h"
#import "NSManagedObjectContext+DNHelpers.h"

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

+ (DNNotification *)clientNotifications:(DNClientNotification *)notification inTempContext:(BOOL)tempContext insertObject:(BOOL)insert {

    //Check if we already have a client notification for this id:
    DNNotification *clientNotification = [DNNotification fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"serverNotificationID == %@ || notificationID == %@", [notification notificationID], [notification notificationID]]
                                                                            withContext:tempContext ? [[DNDataController sharedInstance] temporaryContext]: [[DNDataController sharedInstance] mainContext]];

    if (!clientNotification && insert) {
        clientNotification = [DNNotification insertNewInstanceWithContext:tempContext ? [[DNDataController sharedInstance] temporaryContext] : [[DNDataController sharedInstance] mainContext]];
        [clientNotification setServerNotificationID:[notification notificationID] ? : [DNSystemHelpers generateGUID]];
        [clientNotification setType:[notification notificationType]];
        [clientNotification setAcknowledgementDetails:[notification acknowledgementDetails]];
        [clientNotification setData:[notification data]];
    }

    [clientNotification setSendTries:[notification sendTries]];

    return clientNotification;
}

+ (NSArray *)clientNotificationsWithTempContext:(BOOL)temp {
    NSArray *allNotifications = [DNNotification fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"type != %@", DNCustomNotificationType]
                                           sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:DNType ascending:YES]]
                                               withContext:temp ? [[DNDataController sharedInstance] temporaryContext] : [[DNDataController sharedInstance] mainContext]];
    return [self mappedClientNotifications:allNotifications withTemp:temp];
}

+ (NSArray *)mappedClientNotifications:(NSArray *)allNotifications withTemp:(BOOL)temp {
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

    NSManagedObjectContext *context = temp ? [[DNDataController sharedInstance] temporaryContext] : [[DNDataController sharedInstance] mainContext];

    if ([brokenArray count]) {
        [context deleteAllObjectsInArray:brokenArray];
        [[DNDataController sharedInstance] saveAllData];
    }

    return formattedArray;
}

+ (DNNotification *)contentNotifications:(DNContentNotification *)notification inTempContext:(BOOL)tempContext insertObject:(BOOL)insert {

    //Check if we already have a client notification for this id:
    DNNotification *contentNotification = [DNNotification fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"notificationID == %@ || serverNotificationID == %@", [notification notificationID], [notification notificationID]]
                                                                            withContext:tempContext ? [[DNDataController sharedInstance] temporaryContext] : [[DNDataController sharedInstance] mainContext]];

    if (!contentNotification && insert) {
        contentNotification = [DNNotification insertNewInstanceWithContext:tempContext ? [[DNDataController sharedInstance] temporaryContext] : [[DNDataController sharedInstance] mainContext]];
        [contentNotification setServerNotificationID:[notification notificationID] ?: [DNSystemHelpers generateGUID]];
        [contentNotification setType:DNCustomNotificationType];
        [contentNotification setData:(id) [notification acknowledgementDetails]];
        [contentNotification setAudience:[notification audience]];
        [contentNotification setContent:[notification content]];
        [contentNotification setFilters:[notification filters]];
        [contentNotification setNativePush:[notification nativePush]];
    }

    [contentNotification setSendTries:[notification sendTries]];

    return contentNotification;
}

+ (NSArray *)contentNotificationsWithTempContext:(BOOL)temp {
    NSArray *allNotifications = [DNNotification fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"type == %@", DNCustomNotificationType]
                                           sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:DNType ascending:YES]]
                                               withContext:temp ? [[DNDataController sharedInstance] temporaryContext] : [[DNDataController sharedInstance] mainContext]];
    return [self mappedContentNotification:allNotifications withTemp:temp];
}

+ (NSArray *)mappedContentNotification:(NSArray *)allNotifications withTemp:(BOOL)temp {
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

    NSManagedObjectContext *context = temp ? [[DNDataController sharedInstance] temporaryContext] : [[DNDataController sharedInstance] mainContext];

    if ([brokenArray count]) {
        [context deleteAllObjectsInArray:brokenArray];
        [[DNDataController sharedInstance] saveAllData];
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
        NSManagedObjectContext *context = temp ? [[DNDataController sharedInstance] temporaryContext] : [[DNDataController sharedInstance] mainContext];
        [context deleteAllObjectsInArray:brokenNotifications];
        [[DNDataController sharedInstance] saveAllData];
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
            [self clientNotifications:clientNotification inTempContext:NO insertObject:YES];
        }
    }];
}

+ (NSMutableArray *)sendContentNotifications:(NSArray *)notifications withContext:(NSManagedObjectContext *)context {

    __block NSMutableArray *allNotifications = [[NSMutableArray alloc] init];
    __block NSMutableArray *brokenNotifications = [[NSMutableArray alloc] init];

    [notifications enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[DNContentNotification class]]) {
            DNErrorLog(@"WHoops, something has gone wrong with this client notification. Expected class DNContentNotification, got: %@", NSStringFromClass([obj class]));
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

    [self deleteNotifications:brokenNotifications tempContext:NO];

    return allNotifications;
}

+ (void)saveContentNotificationsToStore:(NSArray *)array {
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[DNContentNotification class]]) {
            DNErrorLog(@"WHoops, something has gone wrong with this client notification. Expected class DNContentNotification, got: %@", NSStringFromClass([obj class]));
        }
        else {
            DNContentNotification *contentNotification = obj;
            [self contentNotifications:contentNotification inTempContext:NO insertObject:YES];
        }
    }];
}

+ (void)deleteNotifications:(NSArray *)notifications tempContext:(BOOL)temp {

    [[DNDataController sharedInstance] saveAllData];

    __block NSMutableArray *storeObjects = [[NSMutableArray alloc] init];

    [notifications enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[DNClientNotification class]]) {
            DNNotification *notification = [self clientNotifications:obj inTempContext:temp insertObject:NO];
            if (notification) {
                [storeObjects addObject:notification];
            }
        }
        else {
            DNNotification *notification = [self contentNotifications:obj inTempContext:temp insertObject:NO];
            if (notification) {
                [storeObjects addObject:notification];
            }
        }
    }];

    if (![storeObjects count]) {
        return;
    }

    NSManagedObjectContext *context = temp ? [[DNDataController sharedInstance] temporaryContext] : [[DNDataController sharedInstance] mainContext];

    if (context) {
        [context deleteAllObjectsInArray:storeObjects];
    }

    [[DNDataController sharedInstance] saveAllData];
}

+ (void)clearBrokenNotificationsWithTempContext:(BOOL)temp {
    //Get all broken types i.e. send tries > 10 && with no valid type:
    NSArray *brokenDonkyNotifications = [DNNotification fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"sendTries >= %d", DNMaximumSendTries]
                                                                  sortDescriptors:nil
                                                                      withContext:temp ? [[DNDataController sharedInstance] temporaryContext] : [[DNDataController sharedInstance] mainContext]];


    if (![brokenDonkyNotifications count]) {
        return;
    }

    NSManagedObjectContext *context = temp ? [[DNDataController sharedInstance] temporaryContext] : [[DNDataController sharedInstance] mainContext];

    if (context) {
        [context deleteAllObjectsInArray:brokenDonkyNotifications];
    }

    [[DNDataController sharedInstance] saveAllData];
}

+ (void)deleteNotificationForID:(NSString *)serverID withTempContext:(BOOL)temp {
    DNNotification *clientNotification = [DNNotification fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"serverNotificationID == %@", serverID]
                                                                            withContext:temp ? [[DNDataController sharedInstance] temporaryContext] : [[DNDataController sharedInstance] mainContext]];

    if (clientNotification) {
        if (temp)
            [[[DNDataController sharedInstance] temporaryContext] deleteObject:clientNotification];
        else
            [[[DNDataController sharedInstance] mainContext] deleteObject:clientNotification];
    }
}

+ (DNNotification *)notificationWithID:(NSString *) notificationID withTempContext:(BOOL)temp {

    DNNotification *clientNotification = [DNNotification fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"serverNotificationID == %@", notificationID]
                                                                            withContext:temp ? [[DNDataController sharedInstance] temporaryContext] : [[DNDataController sharedInstance] mainContext]];

    return clientNotification;
}
@end
