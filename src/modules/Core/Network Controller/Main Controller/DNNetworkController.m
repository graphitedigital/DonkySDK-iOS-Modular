//
//  DNNetworkController.m
//  Core SDK Container
//
//  Created by Chris Watson on 16/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

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
#import "DNRetryHelper.h"
#import "DNConfigurationController.h"
#import "DNAccountController.h"

static NSString *const DNMaxTimeWithoutSynchronise = @"MaxMinutesWithoutNotificationExchange";

static NSString *const DNCustomType = @"customType";

@interface DNNetworkController ()

@property (nonatomic, strong) NSMutableArray *exchangeRequests;

@property (nonatomic, strong) NSMutableArray *queuedCalls;

@property(nonatomic, strong) DNSessionManager *networkSessionManager;

@property (nonatomic, strong) NSMutableArray *pendingClientNotifications;

@property (nonatomic, strong) NSMutableArray *pendingContentNotifications;

@property(nonatomic, strong) DNDeviceConnectivityController *deviceConnectivity;

@property(nonatomic, strong) DNRetryHelper *retryHelper;

@property(nonatomic, strong) NSTimer *synchroniseTimer;

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

    if (self)
    {
        //Create the exchange request array:
        [self setExchangeRequests:[[NSMutableArray alloc] init]];
        [self setQueuedCalls:[[NSMutableArray alloc] init]];
        [self setPendingClientNotifications:[[NSMutableArray alloc] init]];
        [self setPendingContentNotifications:[[NSMutableArray alloc] init]];

        [self setDeviceConnectivity:[[DNDeviceConnectivityController alloc] init]];
        [self setRetryHelper:[[DNRetryHelper alloc] init]];
        [self initialisePendingNotifications];
    }

    return self;
}

- (void)initialisePendingNotifications {
    [[self pendingClientNotifications] addObjectsFromArray:[[DNDataController sharedInstance] clientNotificationsWithTempContext:YES]];
    [[self pendingContentNotifications] addObjectsFromArray:[[DNDataController sharedInstance] contentNotificationsInTempContext:YES]];
}

- (void)startMinimumTimeForSynchroniseBuffer:(NSTimeInterval)buffer {
    if ([self synchroniseTimer])
        [[self synchroniseTimer] invalidate], [self setSynchroniseTimer:nil];

    NSInteger maxTime = [[DNConfigurationController objectFromConfiguration:DNMaxTimeWithoutSynchronise] integerValue];
    if (maxTime > 0) {
        NSTimeInterval interval = (maxTime * 60) - buffer; //Convert to minutes
        if (interval < 0)
            interval = 0; //Guard against 0 value
        [self setSynchroniseTimer:[NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(syncFromTimer) userInfo:nil repeats:NO]];
        [[NSRunLoop mainRunLoop] addTimer:[self synchroniseTimer] forMode:NSDefaultRunLoopMode];
    }
}

#pragma mark -
#pragma mark - Network Calls:

- (void)performSecureDonkyNetworkCall:(BOOL)secure route:(NSString *)route httpMethod:(DonkyNetworkRoute)httpMethod parameters:(id)parameters success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {


    DNRequest *request = [[DNRequest alloc] initWithSecure:secure route:route httpMethod:httpMethod parameters:parameters success:successBlock failure:failureBlock];

    if ([[self deviceConnectivity] hasValidConnection]) {

        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

        if (![DNDonkyNetworkDetails hasValidAccessToken] && secure) {
            [DNNetworkHelper reAuthenticateWithRequest:request failure:failureBlock];
            return;
        }

        //If we are suspended we simply bail out:
        if (secure && [DNDonkyNetworkDetails isSuspended]) {
            if (failureBlock)
                failureBlock(nil, [DNErrorController errorCode:DNCoreSDKSuspendedUser userInfo:@{@"Reason" : @"User is suspended"}]);
            return;
        }

        DNInfoLog(@"Starting network call: %@", route);

        //Ensure there aren't any registration calls happening:
        if (![DNNetworkHelper mandatoryTasksInProgress:self.exchangeRequests]) {
            if (!self.networkSessionManager || [self.networkSessionManager isUsingSecure] != secure)
                self.networkSessionManager = [[DNSessionManager alloc] initWithSecureURl:secure];

            //We remove all non active tasks from the queue:
            [self removeAllCompletedTasksFromQueue];

            //If request is nil then we bail out:
            if (!request) {
                DNErrorLog(@"there is no valid request object: %@\nBailing out ...", request);
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                return;
            }
            
            NSURLSessionTask *currentTask = [DNNetworkHelper performNetworkTaskForRequest:request sessionManager:[self networkSessionManager] success:^(NSURLSessionDataTask *task, id responseData) {
                [self handleSuccess:responseData forTask:task request:request];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [self handleError:error task:task request:request];
            }];

            if (currentTask) {
                [currentTask setTaskDescription:[request route]];
                [[self exchangeRequests] addObject:currentTask];
            }
        }
        else {
            DNInfoLog(@"SDK is in the process of performing a mandatory task... Your request will be performed immediately once these have finished...");
            [[self queuedCalls] addObject:request];
        }
    }
    else {
        [[self deviceConnectivity] addFailedRequestToQueue:request];
        [DNNetworkHelper showNoConnectionAlert];
    }
}

- (void)handleSuccess:(id)responseData forTask:(NSURLSessionDataTask *)task request:(DNRequest *)request {
    if ([DNNetworkHelper mandatoryTasksInProgress:[@[task] mutableCopy]])
        DNSensitiveLog(@"Request %@ successful, response data = %@", [task taskDescription], responseData ? : @"");
    else
       DNInfoLog(@"Request %@ successful, response data = %@", [task taskDescription], responseData ? : @"");

    if ([request successBlock])
        [request successBlock](task, responseData);

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
    [self removeTask:task];
    if (![DNErrorController serviceReturned:400 error:error] && ![DNErrorController serviceReturned:401 error:error] && ![DNErrorController serviceReturned:403 error:error] && ![DNErrorController serviceReturned:404 error:error])
        [[self retryHelper] retryRequest:request task:task];
    else if ([DNErrorController serviceReturned:401 error:error] && ![[request route] isEqualToString:kDNNetworkAuthentication]) {
        //Clear token:
        [DNDonkyNetworkDetails saveTokenExpiry:nil];
        [DNAccountController refreshAccessTokenSuccess:^(NSURLSessionDataTask *task2, id responseData2) {
                [[self retryHelper] retryRequest:request task:task];
        } failure:nil];
    }
    else
        [DNNetworkHelper handleError:error task:task request:request];
}

- (void)serverNotificationForId:(NSString *)notificationID success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    NSString *getNotificationRoute = [NSString stringWithFormat:@"%@%@", kDNNetworkGetNotification, notificationID];
    [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:YES route:getNotificationRoute httpMethod:DNGet parameters:nil success:^(NSURLSessionDataTask *task, id responseData) {
        DNServerNotification *serverNotification = [[DNServerNotification alloc] initWithNotification:responseData];
        [[DNDonkyCore sharedInstance] notificationReceived:serverNotification];
        if (successBlock)
            successBlock(task, serverNotification);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DNErrorLog(@"%@", [error localizedDescription]);
        if (failureBlock)
            failureBlock(task, error);
    }];
}

- (void)allServerNotificationsSuccess:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:YES route:kDNNetworkGetNotification httpMethod:DNGet parameters:nil success:^(NSURLSessionDataTask *task, id responseData) {
        [self processNotificationResponse:@{@"serverNotifications" : responseData} task:task success:nil failure:nil];
        if (successBlock)
            successBlock(task, responseData);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DNErrorLog(@"%@", [error localizedDescription]);
        if (failureBlock)
            failureBlock(task, error);
    }];
}

- (void)syncFromTimer {
    //Check last sync:
    NSTimeInterval timeSinceSync = [[NSDate date] timeIntervalSinceDate:[self lastSynchronise]];
    if (timeSinceSync >= (60 * [[DNConfigurationController objectFromConfiguration:DNMaxTimeWithoutSynchronise] integerValue]))
        [self synchronise];
    else
        [self startMinimumTimeForSynchroniseBuffer:timeSinceSync];
}

- (void)synchronise {
    [self synchroniseSuccess:nil failure:nil];
}

- (void)synchroniseSuccess:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {

    //Set the last sync date
    [self setLastSynchronise:[NSDate date]];
    
    //Update the timer as the current timer now has an invalid time.
    [self synchroniseTimer];
    
    //Remove completed tasks:
    [self removeAllCompletedTasksFromQueue];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        //Get queue:
        __block BOOL isRunning = NO;
        [[self exchangeRequests] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSURLSessionDataTask *task = obj;
            if ([[task taskDescription] isEqualToString:kDNNetworkNotificationSynchronise] && [task state] == NSURLSessionTaskStateRunning) {
                //This is a dupe:
                isRunning = YES;
                *stop = YES;
            }
        }];

        //We bail out as there is already a sync:
        if (isRunning) {
            DNInfoLog(@"Synchronise is already running, cancelling new request: %d", isRunning);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failureBlock)
                    failureBlock(nil, [DNErrorController errorWithCode:DNCoreSDKErrorDuplicateSynchronise]);
            });
            return;
        }

        //Publish:
        [[self pendingClientNotifications] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (![obj isKindOfClass:[DNClientNotification class]]) {
                DNErrorLog(@"Whoops, something has gone wrong, expected class DNClientNotification. Got %@", NSStringFromClass([obj class]));
            }
            else {
                DNClientNotification *notification = obj;
                [[DNDonkyCore sharedInstance] publishOutboundNotification:[notification notificationType] data:notification];
            }
        }];

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

        NSMutableDictionary *params = [[DNDataController sharedInstance] networkClientNotifications:[self pendingClientNotifications]
                                                                        networkContentNotifications:[self pendingContentNotifications]];
        NSArray *sentClientNotifications = [NSArray arrayWithArray:[self pendingClientNotifications]];
        NSArray *sentContentNotifications = [NSArray arrayWithArray:[self pendingContentNotifications]];

        DNInfoLog(@"Sending notifications: %@", params);
        [self performSecureDonkyNetworkCall:YES route:kDNNetworkNotificationSynchronise httpMethod:DNPost parameters:params success:^(NSURLSessionDataTask *task, id responseData) {

            @try {
                [[self pendingClientNotifications] removeObjectsInArray:sentClientNotifications];
                [[self pendingContentNotifications] removeObjectsInArray:sentContentNotifications];

                //We need to clear out these types:
                if ([sentClientNotifications count])
                    [[DNDataController sharedInstance] deleteNotifications:sentClientNotifications inTempContext:YES];
                if ([sentContentNotifications count])
                    [[DNDataController sharedInstance] deleteNotifications:sentContentNotifications inTempContext:YES];

                [self processNotificationResponse:responseData task:nil success:successBlock failure:failureBlock];
            }
            @catch (NSException *exception) {
                DNErrorLog(@"Fatal exception (%@) when processing network response.... Reporting & Continuing", [exception description]);
                [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil]; //Immediately submit to network
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failureBlock)
                        failureBlock(nil, nil);
                });
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            //Save data:
            [[DNDataController sharedInstance] saveClientNotificationsToStore:sentClientNotifications];
            [[DNDataController sharedInstance] saveClientNotificationsToStore:sentContentNotifications];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failureBlock)
                    failureBlock(task, error);
            });
        }];
    });
}

- (void)processNotificationResponse:(id)responseData task:(NSURLSessionDataTask *)task success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    [self removeAllCompletedTasksFromQueue];
    [DNNetworkHelper processNotificationResponse:responseData
                                            task:task
                      pendingClientNotifications:[self pendingClientNotifications]
                     pendingContentNotifications:[self pendingContentNotifications]
                                         success:successBlock
                                         failure:failureBlock];
}

- (NSError *)sendContentNotifications:(NSArray *)notifications success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    NSError *error = [self queueContentNotifications:notifications];
    [self synchroniseSuccess:successBlock failure:failureBlock];
    return error;
}

#pragma mark -
#pragma mark - Notifications

- (void)queueClientNotifications:(NSArray *)notifications {
    [DNNetworkHelper queueClientNotifications:notifications pendingNotifications:[self pendingClientNotifications]];
}

- (NSError *)queueContentNotifications:(NSArray *)notifications {
    return [DNNetworkHelper queueContentNotifications:notifications pendingNotifications:[self pendingContentNotifications]];
}

#pragma mark -
#pragma mark - Network Task Manager

- (void)removeTask:(NSURLSessionTask *)task {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if ([task state] == NSURLSessionTaskStateCompleted) {
        DNInfoLog(@"Clearing completed task: %@", [task taskDescription]);
        [[self exchangeRequests] removeObject:task];
    }
}

- (void)removeAllCompletedTasksFromQueue {
    NSMutableArray *tasksToClear = [[NSMutableArray alloc] init];
    //Clear completed tasks:
    [[self exchangeRequests] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSURLSessionDataTask *task = obj;
        if ([task state] != NSURLSessionTaskStateRunning)
            [tasksToClear addObject:task];
    }];

    if ([tasksToClear count]) {
        DNInfoLog(@"Removing all non running tasks: %@", tasksToClear);
        [self.exchangeRequests removeObjectsInArray:tasksToClear];
    }
}

@end
