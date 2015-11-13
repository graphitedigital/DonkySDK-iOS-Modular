//
//  DNDataController.m
//  NAAS Core SDK Container
//
//  Created by Donky Networks on 16/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNDataController.h"
#import "NSManagedObjectContext+DNHelpers.h"
#import "DNLoggingController.h"

@interface DNDataController ()
@property (nonatomic, strong, readwrite) NSManagedObjectContext *mainContext;
@property (nonatomic, strong, readwrite) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

dispatch_queue_t donkyNetworkCore;

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

-(instancetype)init
{
    return [DNDataController sharedInstance];
}

-(instancetype)initPrivate
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

-(void) applicationDidEnterBackground:(NSNotification *)aNotification {
   [self saveAllData];
}

-(void) applicationWillTerminate:(NSNotification *)aNotification {
    [self saveAllData];
}

- (void)saveAllData {
    [self saveContext:[self mainContext]];
}

- (void)mergeChanges:(NSNotification *)notification {
    
    NSManagedObjectContext *mainContext = [self mainContext];

    // Merge changes into the main context on the main thread
    [mainContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                                  withObject:notification
                               waitUntilDone:YES];

    [mainContext performSelectorOnMainThread:@selector(saveIfHasChanges:) withObject:notification waitUntilDone:YES];
}

#pragma mark - Core Data methods

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
-(NSManagedObjectContext *)mainContext {
    @synchronized (self) {
        if (!_mainContext) {
            _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            [_mainContext setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
        }
        return _mainContext;
    }
}

+ (NSManagedObjectContext *)temporaryContext {
        
    NSManagedObjectContext *privateContext = nil;
    @try {
        privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [privateContext setParentContext:[[DNDataController sharedInstance] mainContext]];
        
        [[NSNotificationCenter defaultCenter] addObserver:[DNDataController sharedInstance] selector:@selector(mergeChanges:) name:NSManagedObjectContextDidSaveNotification object:privateContext];

    }
    @catch (NSException *exception) {
         DNErrorLog(@"Fatal exception (%@) when getting managed contexts.... Reporting & Continuing", [exception description]);
    }
    @finally {
       return privateContext;
    }
}

-(NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
   if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }

    NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];

    NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:@"DNDonkyDataModel.sqlite"];

    // The managed object model for the application.
    // If the model doesn't already exist, it is created from the application's model.
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];

    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];

    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES,
            NSInferMappingModelAutomaticallyOption : @YES};

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        DNErrorLog(@"Fatal, could not load persistent store coordinator. Deleting existing store and creating a new one...");
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        _persistentStoreCoordinator = nil;
        return [self persistentStoreCoordinator];
    }

     return _persistentStoreCoordinator;

}

- (void)saveContext:(NSManagedObjectContext *)context {
    
    if (![context persistentStoreCoordinator]) {
        DNErrorLog(@"Fatal, no persistent store coordinator found in context: %@\nThread: %@", context, [NSThread currentThread]);
        return;
    }
    
    [context saveIfHasChanges:nil];
}

@end
