//
//  DNNetworkController.m
//  Core SDK Container
//
//  Created by Donky Networks on 16/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DNNetworkController.h"
#import "DNSessionManager.h"
#import "DNDeviceConnectivityController.h"
#import "DNDataController.h"
#import "DNNetworkHelper.h"
#import "DNDonkyNetworkDetails.h"
#import "DNDonkyCore.h"
#import "DNConstants.h"
#import "DNLoggingController.h"
#import "DNErrorController.h"
#import "DNContentNotification.h"
#import "DNConfigurationController.h"
#import "DNAccountController.h"
#import "DNNetworkDataHelper.h"
#import "DNSignalRInterface.h"
#import "DNNetworkControllerQueue.h"

static NSString *const DNMaxTimeWithoutSynchronise = @"MaxMinutesWithoutNotificationExchange";
static NSString *const DNCustomType = @"customType";

@interface DNNetworkController ()
@property (nonatomic, strong) dispatch_queue_t donkyNetworkProcessingQueue;
@property (nonatomic, strong) DNDeviceConnectivityController *deviceConnectivity;
@property (nonatomic, strong) NSMutableArray *pendingContentNotifications;
@property (nonatomic, strong) NSMutableArray *pendingClientNotifications;
@property (nonatomic, strong) DNNetworkControllerQueue *controllerQueue;
@property (nonatomic, strong) NSMutableArray *exchangeRequests;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSMutableArray *queuedCalls;
@property (nonatomic, strong) DNRetryHelper *retryHelper;
@property (nonatomic, strong) NSTimer *synchroniseTimer;
@property (nonatomic, strong) NSDate *lastSynchronise;
@end

@implementation DNNetworkController

#pragma mark -
#pragma mark - Setup Singleton

+(DNNetworkController *)sharedInstance
{
    static DNNetworkController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DNNetworkController alloc] initPrivate];

        sharedInstance->_donkyNetworkProcessingQueue = dispatch_queue_create("com.donkySDK.NetworkProcessing", DISPATCH_QUEUE_CONCURRENT);
    });

    
    return sharedInstance;
}

-(instancetype)init
{
    return [DNNetworkController sharedInstance];
}

-(instancetype)initPrivate
{
    self  = [super init];
    
    if (self) {
        
        [self setContext:[[DNDataController sharedInstance] mainContext]];
        
        [self setControllerQueue:[[DNNetworkControllerQueue alloc] init]];
        
        //Create the exchange request array:
        [self setExchangeRequests:[[NSMutableArray alloc] init]];
        [self setQueuedCalls:[[NSMutableArray alloc] init]];
        [self setPendingClientNotifications:[[NSMutableArray alloc] init]];
        [self setPendingContentNotifications:[[NSMutableArray alloc] init]];

        [self setRetryHelper:[[DNRetryHelper alloc] init]];
        [self initialisePendingNotifications];
    }
    
    return self;
}

- (void)initialisePendingNotifications {
    [[self pendingClientNotifications] addObjectsFromArray:[DNNetworkDataHelper clientNotificationsWithContext:[self context]]];
    [[self pendingContentNotifications] addObjectsFromArray:[DNNetworkDataHelper contentNotificationsWithContext:[self context]]];
}

- (void)startMinimumTimeForSynchroniseBuffer:(NSTimeInterval)buffer {
    
    if ([self synchroniseTimer]) {
        [[self synchroniseTimer] invalidate], [self setSynchroniseTimer:nil];
    }
    
    NSInteger maxTime = [[DNConfigurationController objectFromConfiguration:DNMaxTimeWithoutSynchronise] integerValue];
    if (maxTime > 0) {
        NSTimeInterval interval = (maxTime * 60) - buffer; //Convert to minutes
        if (interval < 0) {
            interval = 0; //Guard against 0 value
        }
        [self setSynchroniseTimer:[NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(syncFromTimer) userInfo:nil repeats:NO]];
        [[NSRunLoop mainRunLoop] addTimer:[self synchroniseTimer] forMode:NSDefaultRunLoopMode];
    }
}

#pragma mark -
#pragma mark - Network Calls:

- (void)performSecureDonkyNetworkCall:(BOOL)secure route:(NSString *)route httpMethod:(DonkyNetworkRoute)httpMethod parameters:(id)parameters success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    
    @try {

        if ([[DNDonkyCore sharedInstance] isUsingAuth] && ![DNAccountController isRegistered] && secure) {
            if (failureBlock) {
                failureBlock(nil, [DNErrorController errorCode:DNCoreSDKErrorNotRegistered userInfo:@{@"Reason" : @"Not Registered"}]);
            }
            return;
        }
        
        __weak __typeof(self) weakSelf = self;

        dispatch_async([self donkyNetworkProcessingQueue], ^{
            
            //We remove all non active tasks from the queue:
            [weakSelf removeAllCompletedTasksFromQueue];
            
            if (![weakSelf deviceConnectivity]) {
                [weakSelf setDeviceConnectivity:[[DNDeviceConnectivityController alloc] init]];
            }
            
            DNRequest *request = [[DNRequest alloc] initWithSecure:secure route:route httpMethod:httpMethod parameters:parameters success:successBlock failure:failureBlock];
            
            if ([[weakSelf deviceConnectivity] hasValidConnection]) {
                
                if (![DNDonkyNetworkDetails hasValidAccessToken] && secure) {
                    [DNNetworkHelper reAuthenticateWithRequest:request failure:failureBlock];
                    return;
                }
                
                //If we are suspended we simply bail out:
                if (secure && [DNDonkyNetworkDetails isSuspended]) {
                    if (failureBlock) {
                        failureBlock(nil, [DNErrorController errorCode:DNCoreSDKSuspendedUser userInfo:@{@"Reason" : @"User is suspended"}]);
                    }
                    return;
                }
                
                else if (![DNNetworkHelper isPerformingBlockingTask:[weakSelf exchangeRequests]]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                    });

                    //Create a new session manager:
                    DNSessionManager *sessionManager = [[DNSessionManager alloc] initWithSecureURl:secure];
                    
                    //If request is nil then we bail out:
                    if (!request) {
                        DNErrorLog(@"there is no valid request object: %@\nBailing out ...", request);
                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                        return;
                    }
                    
                    NSURLSessionTask *currentTask = [DNNetworkHelper performNetworkTaskForRequest:request sessionManager:sessionManager success:^(NSURLSessionDataTask *task, id responseData) {
                        dispatch_async([self donkyNetworkProcessingQueue], ^{
                            [weakSelf handleSuccess:responseData forTask:task request:request];
                        });
                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                        dispatch_async([self donkyNetworkProcessingQueue], ^{
                            [weakSelf handleError:error task:task request:request];
                        });
                    }];
                    
                    if (currentTask) {
                        [currentTask setTaskDescription:[request route]];
                        @synchronized ([self exchangeRequests]) {
                            [[self exchangeRequests] addObject:currentTask];
                        }
                    }
                }
                else {
                    //Do we have a duplicate task?
                    @synchronized ([self queuedCalls]) {
                        DNInfoLog(@"Donky is performing protected calls, your request will be performed immediately once these have finished...");
                        if (![[request route] isEqualToString:kDNNetworkAuthentication]) {
                            DNInfoLog(@"Saving Request: %@", [request route]);
                            [[self queuedCalls] addObject:request];
                        }
                    }
                }
            }
            else {
                [[self deviceConnectivity] addFailedRequestToQueue:request];
            }
        });
    }
    @catch (NSException *exception) {
        [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil]; //Immediately submit to network
        if (failureBlock) {
            failureBlock(nil, nil);
        }
    }
}

- (NSProgress *)streamAssetUpload:(NSArray *)assetsToUpload success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {

    if (![DNAccountController isRegistered]) {
        DNErrorLog(@"cannot upload asset, please check user is registered");
        return nil;
    }
    
    NSDictionary *asset = [assetsToUpload firstObject];
    NSError *error2;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:@{@"MimeType" : asset[@"mimeType"], @"Type" : asset[@"type"]} options:0 error:&error2];
    NSString *myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST"
                                                                                 URLString:[[DNDonkyNetworkDetails secureServiceRootUrl] stringByAppendingString:kDNNetworkUploadAsset]
                                                                                parameters:@{@"Test" : @"Nil"} error:nil];

    [request setValue:myString forHTTPHeaderField:@"AssetMetaData"];
    
    NSInputStream *stream = [NSInputStream inputStreamWithData:asset[@"data"]];
    [request setHTTPBodyStream:stream];

    [request setValue:@"DonkyiOSModularSdk" forHTTPHeaderField:@"DonkyClientSystemIdentifier"];
    [request setValue:asset[@"mimeType"] forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", [DNDonkyNetworkDetails accessToken]] forHTTPHeaderField:@"Authorization"];

    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSProgress *progress = nil;

    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request
                                                               fromData:asset[@"data"]
                                                               progress:&progress
                                                      completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if (failureBlock) {
                failureBlock(nil, error);
            }
        } else {
            if (successBlock) {
                successBlock(nil, responseObject);
            }
        }
    }];
    
    [progress addObserver:self
               forKeyPath:@"fractionCompleted"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
 
    [uploadTask resume];
    
    return progress;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"fractionCompleted"] && [object isKindOfClass:[NSProgress class]]) {
        NSProgress *progress = (NSProgress*)object;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:[progress fractionCompleted] != 1];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)handleSuccess:(id)responseData forTask:(NSURLSessionDataTask *)task request:(DNRequest *)request {
    
    if ([request isSecure] && [DNAccountController isSuspended]) {
        [DNAccountController setIsSuspended:NO];
    }

    DNInfoLog(@"Request %@ successful, response data = %@", [task taskDescription], responseData ? : @"");
    
    if ([request successBlock]) {
        [request successBlock](task, responseData);
    }
    else {
        DNInfoLog(@"No Completion block: %@", [request route]);
    }
    
    [self removeTask:task];
    [self performNextTask];
}

- (void)performNextTask {
    DNRequest *nextRequest = [[self queuedCalls] firstObject];
    if (nextRequest) {
        [self performSecureDonkyNetworkCall:[nextRequest isSecure]
                                      route:[nextRequest route]
                                 httpMethod:[nextRequest method]
                                 parameters:[nextRequest parameters]
                                    success:[nextRequest successBlock]
                                    failure:[nextRequest failureBlock]];
        [[self queuedCalls] removeObject:nextRequest];
    }
    else {
        DNInfoLog(@"No more requests in the queue...");
    }
}

- (void)handleError:(NSError *)error task:(NSURLSessionDataTask *)task request:(DNRequest *)request {
    DNErrorLog(@"Network response error: %@", [error localizedDescription]);
    [self removeTask:task];

    if (![DNErrorController serviceReturned:400 error:error] && ![DNErrorController serviceReturned:401 error:error] && ![DNErrorController serviceReturned:403 error:error] && ![DNErrorController serviceReturned:404 error:error])
        [[self retryHelper] retryRequest:request task:task];
    else if ([DNErrorController serviceReturned:401 error:error] && (![[request route] isEqualToString:kDNNetworkAuthentication] && ![[request route] isEqualToString:kDNNetworkAuthenticationAuthenticate])) {
        //Clear token:
        [DNDonkyNetworkDetails saveTokenExpiry:nil];
        [DNAccountController refreshAccessTokenSuccess:^(NSURLSessionDataTask *task2, id responseData2) {
            [[self retryHelper] retryRequest:request task:task];
        } failure:^(NSURLSessionDataTask *task2, NSError *error2) {
            if ([request failureBlock]) {
                [request failureBlock](task2, error2);
            }
        }];
    }
    else {
        [DNNetworkHelper handleError:error task:task request:request];
    }
}

- (void)serverNotificationForId:(NSString *)notificationID success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    NSString *getNotificationRoute = [NSString stringWithFormat:@"%@%@", kDNNetworkGetNotification, notificationID];
    [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:YES route:getNotificationRoute httpMethod:DNGet parameters:nil success:^(NSURLSessionDataTask *task, id responseData) {
        dispatch_async([self donkyNetworkProcessingQueue], ^{
            DNServerNotification *serverNotification = [[DNServerNotification alloc] initWithNotification:responseData];
            NSMutableDictionary *notifications = [[NSMutableDictionary alloc] init];
            notifications[[serverNotification notificationType]] = @[serverNotification];
            [[DNDonkyCore sharedInstance] notificationsReceived:notifications];
            if (successBlock) {
                successBlock(task, serverNotification);
            }
        });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DNErrorLog(@"%@", [error localizedDescription]);
        if (failureBlock) {
            failureBlock(task, error);
        }
    }];
}

- (void)allServerNotificationsSuccess:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:YES route:kDNNetworkGetNotification httpMethod:DNGet parameters:nil success:^(NSURLSessionDataTask *task, id responseData) {
        [self processNotificationResponse:@{@"serverNotifications" : responseData} task:task success:nil failure:nil];
        if (successBlock) {
            successBlock(task, responseData);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DNErrorLog(@"%@", [error localizedDescription]);
        if (failureBlock) {
            failureBlock(task, error);
        }
    }];
}

- (void)syncFromTimer {
    //Check last sync:
    NSTimeInterval timeSinceSync = [[NSDate date] timeIntervalSinceDate:[self lastSynchronise]];
    if (timeSinceSync >= (60 * [[DNConfigurationController objectFromConfiguration:DNMaxTimeWithoutSynchronise] integerValue])) {
        [self synchronise];
    }
    else {
        [self startMinimumTimeForSynchroniseBuffer:timeSinceSync];
    }
}

- (void)synchronise {
    [self synchroniseSuccess:nil failure:nil];
}

- (void)synchroniseSuccess:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    @try {
        dispatch_async([self donkyNetworkProcessingQueue], ^{
            @synchronized (self) {
                if (![self synchroniseTimer]) {
                    [self startMinimumTimeForSynchroniseBuffer:0];
                }

                //Set the last sync date
                [self setLastSynchronise:[NSDate date]];

                //Update the timer as the current timer now has an invalid time.
                [self synchroniseTimer];

                //Remove completed tasks:
                [self removeAllCompletedTasksFromQueue];

                //Publish:
                @synchronized ([self pendingClientNotifications]) {
                    [[self pendingClientNotifications] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        if (![obj isKindOfClass:[DNClientNotification class]]) {
                            DNErrorLog(@"Whoops, something has gone wrong, expected class DNClientNotification. Got %@", NSStringFromClass([obj class]));
                        }
                        else {
                            DNClientNotification *notification = obj;
                            [[DNDonkyCore sharedInstance] publishOutboundNotification:[notification notificationType] data:notification];
                        }
                    }];
                }

                @synchronized ([self pendingContentNotifications]) {
                    [[self pendingContentNotifications] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        if (![obj isKindOfClass:[DNContentNotification class]]) {
                            DNErrorLog(@"Whoops, something has gone wrong, expected class DNContentNotification. Got %@", NSStringFromClass([obj class]));
                        }
                        else {
                            DNContentNotification *notification = obj;
                            NSString *type = [notification content][DNCustomType];
                            [[DNDonkyCore sharedInstance] publishOutboundNotification:type data:notification];
                        }
                    }];
                }

                NSMutableDictionary *params = [DNNetworkDataHelper networkClientNotifications:[self pendingClientNotifications] networkContentNotifications:[self pendingContentNotifications]];
                NSArray *sentClientNotifications = [DNNetworkHelper clientNotifications:[self pendingClientNotifications]];
                NSArray *sentContentNotifications = [DNNetworkHelper contentNotifications:[self pendingContentNotifications]];

                [[self pendingClientNotifications] removeObjectsInArray:sentClientNotifications];
                [[self pendingContentNotifications] removeObjectsInArray:sentContentNotifications];

                //Is data too big?
                CGFloat maxByteSize = [DNConfigurationController maximumSignalRByteSize];

                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                                   options:NSJSONWritingPrettyPrinted
                                                                     error:nil];

                NSString *data = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

                CGFloat byteSize = [data lengthOfBytesUsingEncoding:NSUTF8StringEncoding];

                if ([DNSignalRInterface signalRServiceIsReady] && (maxByteSize && byteSize < maxByteSize)) {

                    [[self controllerQueue] sendData:params completion:^(id response, NSError *error) {
                        if (!error) {
                            @try {
                                @synchronized (self) {
                                    [self cleanUpClientNotifications:sentClientNotifications contentNotifications:sentContentNotifications completion:^(id data2) {
                                        [self processNotificationResponse:response task:nil success:successBlock failure:failureBlock];
                                    }];
                                }
                            }
                            @catch (NSException *exception) {
                                DNErrorLog(@"Fatal exception (%@) when processing network response.... Reporting & Continuing", [exception description]);
                                [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil]; //Immediately submit to network
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (failureBlock) {
                                        failureBlock(nil, nil);
                                    }
                                });
                            }
                        }
                        else {
                            [[self pendingClientNotifications] addObjectsFromArray:sentClientNotifications];
                            [[self pendingContentNotifications] addObjectsFromArray:sentContentNotifications];

                            [DNNetworkDataHelper saveClientNotificationsToStore:sentClientNotifications completion:nil];
                            [DNNetworkDataHelper saveContentNotificationsToStore:sentContentNotifications completion:nil];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (failureBlock) {
                                    failureBlock(nil, error);
                                }
                            });
                        }
                    }];
                }
                else {
                    if ([[self controllerQueue] synchroniseWithParams:params successBlock:^(NSURLSessionDataTask *task, id responseData) {
                        @try {
                            @synchronized (self) {
                                [self cleanUpClientNotifications:sentClientNotifications contentNotifications:sentContentNotifications completion:^(id data2) {
                                    [self processNotificationResponse:responseData task:nil success:successBlock failure:failureBlock];
                                }];
                            }
                        }
                        @catch (NSException *exception) {
                            DNErrorLog(@"Fatal exception (%@) when processing network response.... Reporting & Continuing", [exception description]);
                            [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (failureBlock) {
                                    failureBlock(nil, nil);
                                }
                            });
                        }
                    } failureBlock:^(NSURLSessionDataTask *task, NSError *error) {
                        //Save data:
                        @try {
                            DNInfoLog(@"Notification exchange failed %@", [error localizedDescription]);
                            [[self pendingClientNotifications] addObjectsFromArray:sentClientNotifications];
                            [[self pendingContentNotifications] addObjectsFromArray:sentContentNotifications];

                            [DNNetworkDataHelper saveClientNotificationsToStore:sentClientNotifications completion:^(id data2) {
                                [DNNetworkDataHelper saveContentNotificationsToStore:sentContentNotifications completion:^(id data3) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        if (failureBlock) {
                                            failureBlock(task, error);
                                        }
                                    });
                                }];
                            }];
                        }
                        @catch (NSException *exception) {
                            DNErrorLog(@"Fatal exception (%@) when processing network response.... Reporting & Continuing", [exception description]);
                            [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (failureBlock) {
                                    failureBlock(nil, nil);
                                }
                            });
                        }
                    }]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (failureBlock) {
                                failureBlock(nil, [DNErrorController errorWithCode:DNCoreSDKErrorDuplicateSynchronise]);
                            }
                        });
                    }
                }
            }
        });
    }
    @catch (NSException *exception) {
        [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil];
        DNInfoLog(@"Notification exchange complete");
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failureBlock) {
                failureBlock(nil, nil);
            }
        });
    }
}

- (void)cleanUpClientNotifications:(NSArray *)clientNotifications contentNotifications:(NSArray *)contentNotifications completion:(DNCompletionBlock)completionBlock {
    [DNNetworkDataHelper deleteNotifications:clientNotifications completion:^(id data) {
        [DNNetworkDataHelper deleteNotifications:contentNotifications completion:completionBlock];
    }];
}

- (void)processNotificationResponse:(id)responseData task:(NSURLSessionDataTask *)task success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    [self removeAllCompletedTasksFromQueue];
    [DNNetworkHelper processNotificationResponse:responseData task:task pendingClientNotifications:[self pendingClientNotifications] pendingContentNotifications:[self pendingContentNotifications] success:successBlock failure:failureBlock];
}

- (NSError *)sendContentNotifications:(NSArray *)notifications success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    NSError *error = [self queueContentNotifications:notifications];
    [self synchroniseSuccess:successBlock failure:failureBlock];
    return error;
}

#pragma mark -
#pragma mark - Notifications

- (void)queueClientNotifications:(NSArray *)notifications {
    [self queueClientNotifications:notifications completion:nil];
}

- (void)queueClientNotifications:(NSArray *)notifications completion:(DNCompletionBlock)completionBlock {
    dispatch_async([self donkyNetworkProcessingQueue], ^{
        @synchronized (self) {
            [DNNetworkHelper queueClientNotifications:notifications pendingNotifications:[self pendingClientNotifications] completion:completionBlock];
        }
    });
}

- (NSError *)queueContentNotifications:(NSArray *)notifications {
    return [DNNetworkHelper queueContentNotifications:notifications pendingNotifications:[self pendingContentNotifications]];
}

- (void)queueContentNotifications:(NSArray *)notifications completion:(DNCompletionBlock)completionBlock {
    dispatch_async([self donkyNetworkProcessingQueue], ^{
        @synchronized (self) {
            [DNNetworkHelper queueContentNotifications:notifications pendingNotifications:[self pendingContentNotifications] completon:completionBlock];
        }
    });
}

#pragma mark -
#pragma mark - Network Task Manager

- (void)removeTask:(NSURLSessionTask *)task {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    });
    if ([task state] == NSURLSessionTaskStateCompleted) {
        DNInfoLog(@"Clearing completed task: %@", [task taskDescription]);
        @synchronized ([self exchangeRequests]) {
            [[self exchangeRequests] removeObject:task];
        }
    }
}

- (void)removeAllCompletedTasksFromQueue {
    //Clear completed tasks:
    @synchronized ([self exchangeRequests]) {
        NSMutableArray *tasksToClear = [[NSMutableArray alloc] init];
        [[self exchangeRequests] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSURLSessionDataTask *task = obj;
            if ([task state] != NSURLSessionTaskStateRunning) {
                [tasksToClear addObject:task];
            }
        }];

        if ([tasksToClear count]) {
            DNInfoLog(@"Removing all non running tasks: %@", tasksToClear);
            [[self exchangeRequests] removeObjectsInArray:tasksToClear];
        }
    }
}

@end
