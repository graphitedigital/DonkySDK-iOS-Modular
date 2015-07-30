//
//  DNDataController.m
//  NAAS Core SDK Container
//
//  Created by Chris Watson on 16/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNDataController.h"
#import "NSManagedObjectContext+DNHelpers.h"
#import "DNLoggingController.h"
#import "NSManagedObject+DNHelper.h"
#import "DNNetworkDataHelper.h"
#import "DNAccountController.h"
#import "DNFileHelpers.h"

@interface DNDataController ()
@property (nonatomic, strong, readwrite) NSManagedObjectContext *mainContext;
@property (nonatomic, strong, readwrite) NSManagedObjectContext *temporaryContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
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
    [_mainContext setPersistentStoreCoordinator:[self persistentStoreCoordinator]];

    return _mainContext;
}


- (NSManagedObjectContext *)temporaryContext
{
    if (_temporaryContext != nil) {
        return _temporaryContext;
    }

    _temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_temporaryContext setUndoManager:nil];
    [_temporaryContext setParentContext:[self mainContext]];

    return _temporaryContext;
}

- (NSManagedObjectModel *) managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"DNDonkyDataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

-(NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }

    // The managed object model for the application.
    // If the model doesn't already exist, it is created from the application's model.
//    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    NSURL *storeURL = [[DNFileHelpers urlPathForDocumentDirectory] URLByAppendingPathComponent:@"DNDataController.sqlite"];
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @(YES), NSInferMappingModelAutomaticallyOption: @(YES), NSSQLitePragmasOption: @{@"journal_mode": @"DELETE"}};

    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {

        DNErrorLog(@"Fatal, could not load persistent store coordinator.");
        [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil];
        
    }

    return _persistentStoreCoordinator;
}

-(void)saveMainContext
{
    NSError *error = nil;
    @synchronized ([self mainContext]) {
        [[self mainContext] saveIfHasChanges:&error];
    }

    if (error)
        DNErrorLog(@"Saving context: %@", [error localizedDescription]);
}

-(void)saveTemporaryContext
{
    NSError *error = nil;
    @synchronized ([self temporaryContext]) {
        [[self temporaryContext] saveIfHasChanges:&error];
    }

    if (error)
        DNErrorLog(@"Saving context: %@", [error localizedDescription]);
}

@end
