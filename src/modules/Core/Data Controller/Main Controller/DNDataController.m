//
//  DNDataController.m
//  NAAS Core SDK Container
//
//  Created by Chris Watson on 16/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNDataController.h"
#import "NSManagedObjectContext+DNDelete.h"
#import "NSManagedObjectContext+DNHelpers.h"
#import "DNLoggingController.h"
#import "NSMutableDictionary+DNDictionary.h"
#import "NSManagedObject+DNHelper.h"
#import "DNContentNotification.h"
#import "DNSystemHelpers.h"
#import "DNRichMessage.h"

static const int DNMaximumSendTries = 10;

static NSString *const DNType = @"type";
static NSString *const DNCustomNotificationType = @"Custom";
static NSString *const DNDefinition = @"definition";
static NSString *const DNContent = @"content";
static NSString *const DNFilters = @"filters";
static NSString *const DNAudience = @"audience";
static NSString *const DNSendContent = @"SendContent";
static NSString *const DNAcknowledgementDetails = @"acknowledgementDetail";

@interface DNDataController ()

@property (nonatomic, strong, readwrite) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readwrite) NSManagedObjectContext *mainContext;
@property (nonatomic, strong, readwrite) NSManagedObjectContext *temporaryContext;
@property (nonatomic, strong, readwrite) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation DNDataController

#pragma mark - Singleton

+(DNDataController *)sharedInstance
{
    static dispatch_once_t onceToken;
    static DNDataController *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DNDataController alloc] initPrivate];
    });
    return sharedInstance;
}

-(id)init
{
    return [DNDataController sharedInstance];
}

-(id)initPrivate
{
    self  = [super init];
    if(self)
    {
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];

        [self clearBrokenNotificationsWithTempContext:YES];
    }
    return self;
}

-(void) dealloc
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [notificationCenter removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}

#pragma mark - Application lifecycle methods

-(void) applicationDidEnterBackground:(NSNotification *)aNotification
{
   [self saveAllData];
}

-(void) applicationWillTerminate:(NSNotification *)aNotification
{
    [self saveAllData];
}

- (void)saveAllData {
    [self saveMainContext];
    [self saveTemporaryContext];
}

#pragma mark - Core Data methods

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
-(NSManagedObjectContext *)mainContext
{
    if (_mainContext != nil) {
        return _mainContext;
    }

    _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_mainContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    return _mainContext;
}


- (NSManagedObjectContext *)temporaryContext
{
    if (_temporaryContext != nil) {
        return _temporaryContext;
    }

    _temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    _temporaryContext.undoManager = nil;
    _temporaryContext.parentContext = [self mainContext];
    return _temporaryContext;
}

-(NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];

    NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:@"DNDonkyDataModel.sqlite"];

    // The managed object model for the application.
    // If the model doesn't already exist, it is created from the application's model.
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];

    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];

    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES, NSInferMappingModelAutomaticallyOption : @YES};

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {

#ifdef DEBUG
        // Remove store
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];

        // Then clear user defaults
        [NSUserDefaults resetStandardUserDefaults];

        return nil;
#endif
        
        DNErrorLog(@"Fatal error when trying to access the core data store... aborting");
        abort();
    }

    return _persistentStoreCoordinator;
}

-(void)saveMainContext
{
    NSError *error = nil;
    [[self mainContext] saveIfHasChanges:&error];

    if (error)
        DNErrorLog(@"Saving context: %@", [error localizedDescription]);
}

-(void)saveTemporaryContext
{
    NSError *error = nil;
    [[self temporaryContext] saveIfHasChanges:&error];

    if (error)
        DNErrorLog(@"Saving context: %@", [error localizedDescription]);
}

#pragma mark -
#pragma mark - Helpers

- (DNUserDetails *)currentDeviceUser {

    DNDeviceUser *deviceUser = [DNDeviceUser fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"isDeviceUser == YES"] withContext:[self mainContext]] ? : [self newDevice];

    DNUserDetails *dnUserDetails = [[DNUserDetails alloc] initWithDeviceUser:deviceUser];

    return dnUserDetails;
}

- (void)saveUserDetails:(DNUserDetails *)details {
    DNDeviceUser *deviceUser = [DNDeviceUser fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"isDeviceUser == YES"] withContext:[self mainContext]] ? : [self newDevice];
    [deviceUser setIsAnonymous:@([details isAnonymous])];
    [deviceUser setDisplayName:[details displayName]];
    [deviceUser setMobileNumber:[details mobileNumber]];
    [deviceUser setEmailAddress:[details emailAddress]];
    [deviceUser setAvatarAssetID:[details avatarAssetID]];
    [deviceUser setCountryCode:[details countryCode]];
    [deviceUser setUserID:[details userID]];
    [deviceUser setSelectedTags:[details selectedTags]];
    [deviceUser setAdditionalProperties:[details additionalProperties]];
    [self saveMainContext];
}

- (DNDeviceUser *)newDevice {
    DNDeviceUser *device = [DNDeviceUser insertNewInstanceWithContext:[self mainContext]];
    [device setIsDeviceUser:@(YES)];
    [device setIsAnonymous:@(YES)];
    return device;
}

- (DNNotification *)clientNotifications:(DNClientNotification *)notification inTempContext:(BOOL)tempContext {

    //Check if we already have a client notification for this id:
    DNNotification *clientNotification = [DNNotification fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"serverNotificationID == %@", [notification notificationID]]
                                                                            withContext:tempContext ? [self temporaryContext] : [self mainContext]];

    if (!clientNotification) {
        clientNotification = [DNNotification insertNewInstanceWithContext:tempContext ? [self temporaryContext] : [self mainContext]];
        [clientNotification setServerNotificationID:[notification notificationID] ? : [DNSystemHelpers generateGUID]];
        [clientNotification setType:[notification notificationType]];
        [clientNotification setAcknowledgementDetails:[notification acknowledgementDetails]];
        [clientNotification setData:[notification data]];
    }

    [clientNotification setSendTries:[notification sendTries]];

    return clientNotification;
}

- (NSArray *)clientNotificationsWithTempContext:(BOOL)tempContext {
    NSArray *allNotifications = [DNNotification fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"type != %@", DNCustomNotificationType]
                                           sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:DNType ascending:YES]]
                                               withContext:tempContext ? [self temporaryContext] : [self mainContext]];
    return [self mappedClientNotifications:allNotifications];
}

- (NSArray *)mappedClientNotifications:(NSArray *)allNotifications {
    NSMutableArray *formattedArray = [[NSMutableArray alloc] init];

    [allNotifications enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DNNotification *storeNotification = obj;
        DNClientNotification *notification = [[DNClientNotification alloc] initWithNotification:storeNotification];
        [formattedArray addObject:notification];
    }];

    return formattedArray;
}

- (DNNotification *)contentNotifications:(DNContentNotification *)notification inTempContext:(BOOL)tempContext {

    //Check if we already have a client notification for this id:
    DNNotification *contentNotification = [DNNotification fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"serverNotificationID == %@", [notification notificationID]]
                                                                            withContext:tempContext ? [self temporaryContext] : [self mainContext]];

    if (!contentNotification) {
        contentNotification = [DNNotification insertNewInstanceWithContext:tempContext ? [self temporaryContext] : [self mainContext]];
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

- (NSArray *)contentNotificationsInTempContext:(BOOL)tempContext {
    NSArray *allNotifications = [DNNotification fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"type == %@", DNCustomNotificationType]
                                           sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:DNType ascending:YES]]
                                               withContext:tempContext ? [self temporaryContext] : [self mainContext]];
    return [self mappedContentNotification:allNotifications];
}

- (NSArray *)mappedContentNotification:(NSArray *)allNotifications {
    NSMutableArray *formattedArray = [[NSMutableArray alloc] init];

    [allNotifications enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DNNotification *storeNotification = obj;
        DNContentNotification *notification = [[DNContentNotification alloc] initWithAudience:[storeNotification audience]
                                                                                      filters:[storeNotification filters]
                                                                                      content:[storeNotification content]
                                                                                   nativePush:[storeNotification nativePush]];
        [formattedArray addObject:notification];
    }];

    return formattedArray;
}

- (NSMutableDictionary *)networkClientNotifications:(NSMutableArray *)clientNotifications networkContentNotifications:(NSMutableArray *)contentNotifications {

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

            if ([originalNotification acknowledgementDetails])
                [formattedNotification dnSetObject:[originalNotification acknowledgementDetails] forKey:DNAcknowledgementDetails];

            [[originalNotification data] enumerateKeysAndObjectsUsingBlock:^(id key, id obj2, BOOL *stop2) {
                [formattedNotification dnSetObject:obj2 forKey:key];
            }];

            if (![self checkForBrokenNotification:formattedNotification])
                [allNotifications addObject:formattedNotification];
            else
                [brokenNotifications addObject:originalNotification];
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

            if (![self checkForBrokenNotification:formattedNotification])
                [allNotifications addObject:formattedNotification];
            else
                [brokenNotifications addObject:originalNotification];
        }
    }];

    [self deleteNotifications:brokenNotifications inTempContext:YES];

    //We save the send tries increment:
    [self saveAllData];

    //Prepare return:
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params dnSetObject:allNotifications forKey:@"clientNotifications"];
    [params dnSetObject:[[UIApplication sharedApplication] applicationState] != UIApplicationStateActive ? @"false" : @"true" forKey:@"isBackground"];
    return params;
}

- (BOOL)checkForBrokenNotification:(NSMutableDictionary *)dictionary {
    //Do we have a type:
    NSString *type = dictionary[DNType];
    return !type;
}

- (void)saveClientNotificationsToStore:(NSArray *)array {
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[DNClientNotification class]]) {
            DNErrorLog(@"WHoops, something has gone wrong with this client notification. Expected class DNClientNotification, got: %@", NSStringFromClass([obj class]));
        }
        else {
            DNClientNotification *clientNotification = obj;
            [self clientNotifications:clientNotification inTempContext:YES];
        }
    }];

    [self saveAllData];
}

- (NSMutableArray *)sendContentNotifications:(NSArray *)notifications {

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

    [self deleteNotifications:brokenNotifications inTempContext:YES];

    return allNotifications;
}

- (void)saveContentNotificationsToStore:(NSArray *)array {
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[DNContentNotification class]]) {
            DNErrorLog(@"WHoops, something has gone wrong with this client notification. Expected class DNContentNotification, got: %@", NSStringFromClass([obj class]));
        }
        else {
            DNContentNotification *contentNotification = obj;
            [self contentNotifications:contentNotification inTempContext:YES];
        }
    }];

    [self saveAllData];
}


- (void)deleteNotifications:(NSArray *)notifications inTempContext:(BOOL)tempContext {

    __block NSMutableArray *storeObjects = [[NSMutableArray alloc] init];

    [notifications enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[DNClientNotification class]])
            [storeObjects addObject:[self clientNotifications:obj inTempContext:YES]];
        else
            [storeObjects addObject:[self contentNotifications:obj inTempContext:YES]];
    }];

    if (tempContext)
        [[self temporaryContext] deleteAllObjectsInArray:storeObjects];
    else
        [[self mainContext] deleteAllObjectsInArray:storeObjects];

    [self saveAllData];
}

- (void)clearBrokenNotificationsWithTempContext:(BOOL)tempContext {
    //Get all broken types i.e. send tries > 10 && with no valid type:
    NSArray *brokenDonkyNotifications = [DNNotification fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"sendTries >= %d", DNMaximumSendTries] sortDescriptors:nil withContext:tempContext ? [self temporaryContext] : [self mainContext]];
    if (tempContext)
        [[self temporaryContext] deleteAllObjectsInArray:brokenDonkyNotifications];
    else
        [[self mainContext] deleteAllObjectsInArray:brokenDonkyNotifications];

    [self saveAllData];
}

- (void)deleteNotificationForID:(NSString *)serverID withTempContext:(BOOL)temp {
    DNNotification *clientNotification = [DNNotification fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"serverNotificationID == %@", serverID]
                                                                            withContext:temp ? [self temporaryContext] : [self mainContext]];

    if (clientNotification) {
        if (temp)
            [[self temporaryContext] deleteObject:clientNotification];
        else
            [[self mainContext] deleteObject:clientNotification];
    }
}

- (DNNotification *)notificationWithID:(NSString *) notificationID withTempContext:(BOOL)temp {

    DNNotification *clientNotification = [DNNotification fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"serverNotificationID == %@", notificationID]
                                                                            withContext:temp ? [self temporaryContext] : [self mainContext]];

    return clientNotification;
}


#pragma mark -
#pragma mark - Messaging:

- (NSArray *)unreadRichMessages:(BOOL)unread tempContext:(BOOL)tempContext {
    return [DNRichMessage fetchObjectsWithPredicate:unread ? [NSPredicate predicateWithFormat:@"read == NO"] : nil
                                    sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"messageID" ascending:YES]]
                                        withContext:tempContext ? [self temporaryContext] : [self mainContext]];
}

- (DNRichMessage *)richMessageForID:(NSString *)messageID tempContext:(BOOL)tempContext {
    DNRichMessage *message = [DNRichMessage fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"messageID == %@", messageID]
                                                               withContext:tempContext ? [self temporaryContext] : [self mainContext]];
    if (!message) {
        message = [DNRichMessage insertNewInstanceWithContext:tempContext ? [self temporaryContext] : [self mainContext]];
        [message setMessageID:messageID];
        [message setRead:@(NO)];
    }

    return message;
}

- (void)deleteRichMessage:(NSString *)messageID tempContext:(BOOL)tempContext {
    DNRichMessage *richMessage = [self richMessageForID:messageID tempContext:tempContext];
    if (richMessage) {
        if (tempContext)
            [[self temporaryContext] deleteObject:richMessage];
        else
            [[self mainContext] deleteObject:richMessage];
    }
}

- (NSArray *)filterRichMessage:(NSString *)filter tempContext:(BOOL)tempContext {
    return [DNRichMessage fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"messageDescription cd == %@", filter]
                                    sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sentTimeStamp" ascending:YES]]
                                        withContext:tempContext ? [self temporaryContext]  : [self mainContext]];
}

@end
