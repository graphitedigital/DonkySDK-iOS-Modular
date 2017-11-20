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

@interface DNDataController ()
@property (nonatomic, strong) dispatch_queue_t donkyCoreDataProcessingQueue;
@property (nonatomic, strong, readwrite) NSManagedObjectContext *mainContext;
@property (nonatomic, strong, readwrite) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSMutableDictionary *completionBlocks;
@property (atomic, strong) NSMutableSet<NSManagedObjectContext*> *privateContexts;
@end

@implementation DNDataController

#pragma mark - Singleton

+(DNDataController *)sharedInstance
{
    static dispatch_once_t onceToken;
    static DNDataController *sharedInstance = nil;

    dispatch_once(&onceToken, ^{
        sharedInstance = [[DNDataController alloc] initPrivate];

        sharedInstance->_donkyCoreDataProcessingQueue = dispatch_queue_create("com.donkySDK.CoreDataProcessing", DISPATCH_QUEUE_CONCURRENT);
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

        _privateContexts = [NSMutableSet set];
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

    dispatch_async(dispatch_get_main_queue(), ^(){
        NSError *error = nil;
        [mainContext saveIfHasChanges:&error];
        dispatch_async([self donkyCoreDataProcessingQueue], ^{
            [self invokeSaveBlock:notification];
        });
    });


    if (![DNSystemHelpers systemVersionAtLeast:10.0]) {

        dispatch_async([self donkyCoreDataProcessingQueue], ^{
            @synchronized (self.privateContexts) {
                DNInfoLog(@"Updating all of the other child contexts with the changes");
                //we need to operate on copy, as the set can be updated on the other threads
                for(NSManagedObjectContext *context in self.privateContexts){
                    if(![context isEqual:notification.object]){
                        [context mergeChangesFromContextDidSaveNotification:notification];
                    }
                }
            }
        });
    }
}

#pragma mark - Core Data methods

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
-(NSManagedObjectContext *)mainContext {
    dispatch_sync([self donkyCoreDataProcessingQueue], ^{
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (!_mainContext) {
                _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
                [_mainContext setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
            }
        });
    });

    return _mainContext;
}

+ (NSManagedObjectContext *)temporaryContext {

    NSManagedObjectContext *privateContext = nil;
    @try {
        privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [privateContext setParentContext:[[DNDataController sharedInstance] mainContext]];
        if ([DNSystemHelpers systemVersionAtLeast:10.0]) {
            //with iOS < 10 the merging is handled manually in the -mergeChanges: selector
            privateContext.automaticallyMergesChangesFromParent = YES;
        }

        [[NSNotificationCenter defaultCenter] addObserver:[DNDataController sharedInstance]
                                                 selector:@selector(mergeChanges:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:privateContext];

    }
    @catch (NSException *exception) {
        DNErrorLog(@"Fatal exception (%@) when getting managed contexts.... Reporting & Continuing", [exception description]);
    }
    @finally {
         if (![DNSystemHelpers systemVersionAtLeast:10.0]) {
            @synchronized ([DNDataController sharedInstance].privateContexts) {
                [[DNDataController sharedInstance].privateContexts addObject:privateContext];
            }
         }

        return privateContext;
    }
}

-(NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }

    dispatch_sync([self donkyCoreDataProcessingQueue], ^{
        NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];

        NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:@"DNDonkyDataModel.sqlite"];

        // The managed object model for the application.
        // If the model doesn't already exist, it is created from the application's model.
        NSBundle *bundle =[NSBundle bundleForClass:[self class]];
        NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: [bundle URLForResource:@"DNDonkyDataModel" withExtension:@"momd"] ];

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
        }
    });

    if (!_persistentStoreCoordinator) {
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

- (void)saveContext:(NSManagedObjectContext *)context completion:(DNCompletionBlock)completion {
    if (![context persistentStoreCoordinator]) {
        DNErrorLog(@"Fatal, no persistent store coordinator found in context: %@\nThread: %@", context, [NSThread currentThread]);
        return;
    }

    dispatch_async([self donkyCoreDataProcessingQueue], ^{
        DNInfoLog(@"Saving to DB, has changes: %d", [context hasChanges]);
        if (![context hasChanges]) {
            if (completion) {
                completion(nil);
            }
        }
        else {
            @synchronized ([self completionBlocks]) {
                if (completion) {
                    [[self completionBlocks] setObject:[completion copy] forKey:[context description]];
                }

                [context saveIfHasChanges:nil];
            }
        }
    });
}

- (void)invokeSaveBlock:(NSNotification *)notification {
    DNInfoLog(@"Invoking save block");
    //This needs refinement:
    dispatch_async([self donkyCoreDataProcessingQueue], ^{

        @synchronized ([self completionBlocks]) {
            DNCompletionBlock completionBlock = [self completionBlocks][[[notification object] description]];

            if (completionBlock) {
                completionBlock(notification);
                [[self completionBlocks] removeObjectForKey:[[notification object] description]];

                 if (![DNSystemHelpers systemVersionAtLeast:10.0]) {
                    @synchronized (self.privateContexts) {
                        [self.privateContexts removeObject:notification.object];
                    }
                 }
            }
        }
    });
}

@end
