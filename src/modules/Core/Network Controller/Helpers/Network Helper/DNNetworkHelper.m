//
//  DNNetworkHelper.m
//  Core Container
//
//  Created by Chris Watson on 17/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//
#import "DNNetworkHelper.h"
#import "DNConstants.h"
#import "DNLoggingController.h"
#import "DNErrorController.h"
#import "DNSynchroniseResponse.h"
#import "DNServerNotification.h"
#import "DNDonkyCore.h"
#import "DNAppSettingsController.h"
#import "DNSystemHelpers.h"
#import "DNNetwork+Localization.h"
#import "UIViewController+DNRootViewController.h"
#import "DNContentNotification.h"
#import "DNDataController.h"
#import "DNConfigurationController.h"
#import "DNAccountController.h"
#import "DNDonkyNetworkDetails.h"
#import "DNNetworkDataHelper.h"


static NSString *const DNDeviceNotFound = @"DeviceNotFound";

@implementation DNNetworkHelper

+ (BOOL)isPerformingBlockingTask:(NSMutableArray *)exchangeRequests {

    @synchronized (exchangeRequests) {
        __block BOOL isPerformingBlockingTask = NO;

        [exchangeRequests enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSURLSessionDataTask *task = obj;
            if (([[task taskDescription] isEqualToString:kDNNetworkRegistration] ||
                    [[task taskDescription] isEqualToString:kDNNetworkAuthentication] ||
                    [[task taskDescription] isEqualToString:kDNNetworkRegistrationDeviceUser] ||
                    [[task taskDescription] isEqualToString:kDNNetworkRegistrationDevice] ||
                    [[task taskDescription] isEqualToString:kDNNetworkRegistrationClient]) &&
                    [task state] != NSURLSessionTaskStateCompleted) {
                isPerformingBlockingTask = YES;
                *stop = YES;
            }
        }];

        return isPerformingBlockingTask;
    }
}

+ (BOOL)isCallNecessary:(DNRequest *)request {
    return !([[request route] isEqualToString:kDNNetworkRegistration] && [DNAccountController isRegistered]);
}

+ (BOOL)isRequest:(DNRequest *)request duplicated:(NSMutableArray *)queuedRequests {

    __block BOOL isDuplicate = NO;

    [queuedRequests enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DNRequest *currentRequest = obj;
        if ([[currentRequest route] isEqualToString:[request route]] && (![[currentRequest route] isEqualToString:kDNNetworkRegistrationClient] && ![[currentRequest route] isEqualToString:kDNNetworkRegistrationDevice]  && ![[currentRequest route] isEqualToString:kDNNetworkRegistrationDeviceUser])) {
            isDuplicate = YES;
            *stop = YES;
        }
    }];

    return isDuplicate;
}

+ (void)handleError:(NSError *)error task:(NSURLSessionDataTask *)task request:(DNRequest *)request {
    NSData *data = [error userInfo][AFNetworkingOperationFailingURLResponseDataErrorKey];
    NSMutableDictionary *errorDictionary = nil;
    if (data) {
        id errorObject = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions) kNilOptions error:nil];
        if ([errorObject isKindOfClass:[NSArray class]])
            errorDictionary = [[errorObject firstObject] mutableCopy];
        else if ([errorObject isKindOfClass:[NSDictionary class]])
            errorDictionary = errorObject;
        else
            DNInfoLog(@"unhandled error object of type: %@\n%@", [errorObject class], [error localizedDescription]);
    }

    DNErrorLog(@"Request %@ failed, error result = %@", [task taskDescription], errorDictionary ? : [error localizedDescription]);

    NSError *newError = nil;
    if (errorDictionary)
        newError = [DNErrorController errorCode:DNCoreSDKNetworkError userInfo:errorDictionary];

    if ([request failureBlock])
        [request failureBlock](task, newError ? : error);

    //Retry policy:
    [DNNetworkHelper deviceUserDeleted:newError ? : error];
}

+ (void)deviceUserDeleted:(NSError *)error {
    if ([DNErrorController serviceReturnedFailureKey:DNDeviceNotFound error:error]) {
        [DNDonkyNetworkDetails saveNetworkID:nil];
        [DNAccountController initialiseUserDetails:[[DNAccountController registrationDetails] userDetails] 
                                     deviceDetails:[[DNAccountController registrationDetails] deviceDetails] 
                                           success:nil 
                                           failure:nil];
    }
}

+ (void)queueClientNotifications:(NSArray *)notifications pendingNotifications:(NSMutableArray *)pendingNotifications {
    //Enumerate through the array:
    [notifications enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[DNClientNotification class]]) {
            DNErrorLog(@"Whoops, something has gone wrong, expected class DNClientNotification. Got %@", NSStringFromClass([obj class]));
        }
        else {
            @synchronized (pendingNotifications) {
                if (![pendingNotifications containsObject:obj]) {
                    [pendingNotifications addObject:obj];
                }
            }
        }
    }];

    [DNNetworkDataHelper saveClientNotificationsToStore:notifications];
}

+ (NSError *)queueContentNotifications:(NSArray *)notifications pendingNotifications:(NSMutableArray *)pendingNotifications{

    NSMutableArray *acceptableNotifications = [[NSMutableArray alloc] init];
    NSMutableArray *unAcceptableNotifications = [[NSMutableArray alloc] init];

    CGFloat maxByteSize = [DNConfigurationController maximumContentByteSize];

    [notifications enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[DNContentNotification class]]) {
            DNErrorLog(@"Whoops, something has gone wrong, expected class DNContentNotification. Got %@", NSStringFromClass([obj class]));
        }
        else {

            //Check the size:
            DNContentNotification *notification = obj;

            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[notification content]
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:nil];

            NSString *data = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

            CGFloat byteSize = [data lengthOfBytesUsingEncoding:NSUTF8StringEncoding];

            if (maxByteSize && byteSize > maxByteSize) {
                [unAcceptableNotifications addObject:notification];
            }
            else {
                @synchronized (pendingNotifications) {
                    if (![pendingNotifications containsObject:obj]) {
                        [pendingNotifications addObject:obj];
                    }
                    [acceptableNotifications addObject:notification];
                }
            }
        }
    }];

    if ([unAcceptableNotifications count]) {
        NSError *error = [DNErrorController errorCode:DNCoreContentNotificationSizeLimit additionalData:unAcceptableNotifications];
        return error;
    }

    [DNNetworkDataHelper saveContentNotificationsToStore:acceptableNotifications];

    return nil;
}

+ (void)processNotificationResponse:(id)responseData task:(NSURLSessionDataTask *)task pendingClientNotifications:(NSMutableArray *)pendingClientNotifications pendingContentNotifications:(NSMutableArray *)pendingContentNotifications success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {
    //The response object will now have all of the data from the server.
    @try {
        DNSynchroniseResponse *response = [[DNSynchroniseResponse alloc] initWithDonkyNetworkResponse:responseData];

        [[response failedClientNotifications] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            DNErrorLog(@"Failed client notification: %@", obj);
            //We need the notification id:
            NSString *serverID = [DNNetworkHelper failedClientNotificationServerID:obj];
            if (serverID) {
                [DNNetworkDataHelper deleteNotificationForID:serverID withTempContext:YES];
            }
        }];


        //Lets process the response
        __block NSMutableDictionary *responseBatches = [[NSMutableDictionary alloc] init];

        [[response serverNotifications] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            DNServerNotification *serverNotification = [[DNServerNotification alloc] initWithNotification:obj];
            NSMutableArray *batch = responseBatches[[serverNotification notificationType]] ? : [[NSMutableArray alloc] init];
            if (![serverNotification serverNotificationID]) {
                DNErrorLog(@"Cannot save notification %@ - No ID.", serverNotification);
            }
            else {
                [batch addObject:serverNotification];

                responseBatches[[serverNotification notificationType]] = batch;
            }
        }];

        if ([[responseBatches allKeys] count]) {
            [[DNDonkyCore sharedInstance] notificationsReceived:responseBatches];
        }

        //The network sends a maximum of 100 notifications at a time, in this case we need to perform the request again before completing:
        if ([response moreNotificationsAvailable] || [pendingClientNotifications count] || [pendingContentNotifications count]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[DNDataController sharedInstance] saveAllData];
                [[DNNetworkController sharedInstance] synchroniseSuccess:successBlock failure:failureBlock];
            });
        }
        else {
            if (successBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[DNDataController sharedInstance] saveAllData];
                    successBlock(task, nil); //We don't return the response data as the core library handles this.
                });
            }
        }
    }
    @catch (NSException *exception) {
        DNErrorLog(@"Fatal exception (%@) when processing network response.... Retporting & Continuing", [exception description]);
        [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil]; //Immediately submit to network
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failureBlock) {
                failureBlock(nil, nil);
            }
        });
    }
}

+ (NSString *)failedClientNotificationServerID:(id)obj {
    return obj[@"notification"][@"acknowledgementDetail"][@"serverNotificationId"];
}

+ (void)showNoConnectionAlert {

    if ([DNAppSettingsController displayNoInternetAlert]) {
        if ([DNSystemHelpers systemVersionAtLeast:8.0]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:DNNetworkLocalizedString(@"dn_network_no_internet_tile")
                                                                                     message:DNNetworkLocalizedString(@"dn_network_no_internet_message")
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:DNNetworkLocalizedString(@"dn_network_no_internet_button") style:UIAlertActionStyleDefault handler:nil]];
            UIViewController *rootView = [[[DNDonkyCore sharedInstance] applicationWindow] rootViewController] ? : [UIViewController applicationRootViewController];
            if ([rootView isViewLoaded]) {
                if (!rootView) {
                    DNErrorLog(@"Couldn't present alert view, root view is nil.");
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [rootView presentViewController:alertController animated:YES completion:nil];
                    });
                }
            }
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:DNNetworkLocalizedString(@"dn_network_no_internet_tile")
                                                                message:DNNetworkLocalizedString(@"dn_network_no_internet_message")
                                                               delegate:nil
                                                      cancelButtonTitle:DNNetworkLocalizedString(@"dn_network_no_internet_button")
                                                      otherButtonTitles:nil];
            [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        }
    }
}

+ (void)reAuthenticateWithRequest:(DNRequest *)request failure:(DNNetworkFailureBlock)failureBlock {

    DNInfoLog(@"Authentication token expired. Re-Authenticating and then continuing with request...");
    [DNAccountController refreshAccessTokenSuccess:^(NSURLSessionDataTask *task, id responseData) {
        [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:[request isSecure]
                                      route:[request route]
                                 httpMethod:[request method]
                                 parameters:[request parameters]
                                    success:[request successBlock]
                                    failure:[request failureBlock]];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DNErrorLog(@"%@", [error localizedDescription]);
        if (failureBlock)
            failureBlock(task, error);
    }];

}

+ (NSURLSessionTask *)performNetworkTaskForRequest:(DNRequest *)request sessionManager:(DNSessionManager *)sessionManager success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {

    NSURLSessionTask *currentTask = nil;
    switch ([request method]) {
        case DNPost: {
            currentTask = [sessionManager performPostWithRoute:[request route] parameteres:[request parameters] success:^(NSURLSessionDataTask *task, id responseData) {
                if (successBlock)
                    successBlock(task, responseData);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (failureBlock)
                    failureBlock(task, error);
            }];
        }
            break;
        case DNGet: {
            currentTask = [sessionManager performGetWithRoute:[request route] parameteres:[request parameters] success:^(NSURLSessionDataTask *task, id responseData) {
                if (successBlock)
                    successBlock(task, responseData);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (failureBlock)
                    failureBlock(task, error);
            }];
        }
            break;
        case DNDelete: {
            currentTask = [sessionManager performDeleteWithRoute:[request route] parameteres:[request parameters] success:^(NSURLSessionDataTask *task, id responseData) {
                if (successBlock)
                    successBlock(task, responseData);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (failureBlock)
                    failureBlock(task, error);
            }];
        }
            break;
        case DNPut: {
            currentTask = [sessionManager performPutWithRoute:[request route] parameteres:[request parameters] success:^(NSURLSessionDataTask *task, id responseData) {
                if (successBlock)
                    successBlock(task, responseData);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (failureBlock)
                    failureBlock(task, error);
            }];
        }
            break;
        case DNNone:
            break;
    }

    return currentTask;
}

@end
