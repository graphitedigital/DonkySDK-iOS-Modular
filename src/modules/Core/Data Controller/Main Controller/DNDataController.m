//
//  DNDataController.m
//  NAAS Core SDK Container
//
//  Created by Donky Networks on 16/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DNDataController.h"
#import "NSManagedObjectContext+DNHelpers.h"
#import "DNLoggingController.h"
#import "DNSystemHelpers.h"
#import "DNQueueManager.h"

@interface DNDataController ()
@property (nonatomic, strong, readwrite) NSManagedObjectContext *mainContext;
@property (nonatomic, strong, readwrite) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSMutableDictionary *completionBlocks;
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

-(instancetype)init
{
    return [DNDataController sharedInstance];
}

-(instancetype)initPrivate
{
    self = [super init];

    if (self) {
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];

        [self setCompletionBlocks:[[NSMutableDictionary alloc] init]];
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

-(void)applicationDidEnterBackground:(NSNotification *)aNotification {
   [self saveAllData];
}

-(void)applicationWillTerminate:(NSNotification *)aNotification {
    [self saveAllData];
}

- (void)saveAllData {
    [self saveContext:[self mainContext]];
}

- (void)mergeChanges:(NSNotification *)notification {
    DNInfoLog(@"Merging changes into main context: %@", notification);

    NSManagedObjectContext *mainContext = [self mainContext];
    
    // Merge changes into the main context on the main thread
    [mainContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                                  withObject:notification
                               waitUntilDone:YES];

    [mainContext performSelectorOnMainThread:@selector(saveIfHasChanges:)
                                  withObject:notification
                               waitUntilDone:YES];

    [self invokeSaveBlock:notification];
}

#pragma mark - Core Data methods

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
-(NSManagedObjectContext *)mainContext {
    if (!_mainContext) {
        _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_mainContext setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
    }
    return _mainContext;
}

+ (NSManagedObjectContext *)temporaryContext {
        
    NSManagedObjectContext *privateContext = nil;
    @try {
        privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [privateContext setParentContext:[[DNDataController sharedInstance] mainContext]];
        
        [[NSNotificationCenter defaultCenter] addObserver:[DNDataController sharedInstance]
                                                 selector:@selector(mergeChanges:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:privateContext];

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

    @synchronized (self) {
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
            if ([DNSystemHelpers systemVersionAtLeast:9.0]) {
                [_persistentStoreCoordinator destroyPersistentStoreAtURL:storeURL withType:NSSQLiteStoreType options:options error:&error];
            }
            [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
            _persistentStoreCoordinator = nil;
            return [self persistentStoreCoordinator];
        }

        return _persistentStoreCoordinator;
    }
}

- (void)saveContext:(NSManagedObjectContext *)context {
    
    if (![context persistentStoreCoordinator]) {
        DNErrorLog(@"Fatal, no persistent store coordinator found in context: %@\nThread: %@", context, [NSThread currentThread]);
        return;
    }

    [context saveIfHasChanges:nil];
}

- (void)saveContext:(NSManagedObjectContext *)context completion:(DNCompletionBlock)completion {
    if (![context persistentStoreCoordinator]) {
        DNErrorLog(@"Fatal, no persistent store coordinator found in context: %@\nThread: %@", context, [NSThread currentThread]);
        return;
    }

    @synchronized (self) {
        DNInfoLog(@"Saving to DB, has changes: %d", [context hasChanges]);
        if (![context hasChanges]) {
            if (completion){
                completion(nil);
            }
        }
        else {
            if (completion) {
                [[self completionBlocks] setObject:completion forKey:[context description]];
            }
            [context saveIfHasChanges:nil];
        }
    }
}

- (void)invokeSaveBlock:(NSNotification *)notification {
    DNInfoLog(@"Invoking save block");
    //This needs refinement:
    dispatch_async(donky_logic_processing_queue(), ^{
        DNCompletionBlock completionBlock = [self completionBlocks][[[notification object] description]];
        if (completionBlock) {
            completionBlock(notification);
            @synchronized (self) {
                [[self completionBlocks] removeObjectForKey:[[notification object] description]];
            }
        }
    });
}

@end