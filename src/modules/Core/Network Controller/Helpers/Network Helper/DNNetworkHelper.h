//
//  DNNetworkHelper.h
//  Core Container
//
//  Created by Donky Networks on 17/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNBlockDefinitions.h"
#import "DNRequest.h"
#import "DNSessionManager.h"

@interface DNNetworkHelper : NSObject

+ (BOOL)isPerformingBlockingTask:(NSMutableArray *)exchangeRequests;

+ (void)handleError:(NSError *)error task:(NSURLSessionDataTask *)task request:(DNRequest *)request;

+ (void)deviceUserDeleted:(NSError *)error;

+ (void)queueClientNotifications:(NSArray *)notifications pendingNotifications:(NSMutableArray *)pendingNotifications completion:(DNCompletionBlock)completionBlock;

+ (NSError *)queueContentNotifications:(NSArray *)notifications pendingNotifications:(NSMutableArray *)pendingNotifications;

+ (void)queueContentNotifications:(NSArray *)notifications pendingNotifications:(NSMutableArray *)pendingNotifications completon:(DNCompletionBlock)completionBlock;

+ (void)processNotificationResponse:(id)responseData task:(NSURLSessionDataTask *)task pendingClientNotifications:(NSMutableArray *)pendingClientNotifications pendingContentNotifications:(NSMutableArray *)pendingContentNotifications success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

+ (void)showNoConnectionAlert;

+ (void)reAuthenticateWithRequest:(DNRequest *)request failure:(DNNetworkFailureBlock)failureBlock;

+ (NSURLSessionTask *)performNetworkTaskForRequest:(DNRequest *)request sessionManager:(DNSessionManager *)sessionManager success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

+ (NSArray *)clientNotifications:(NSMutableArray *)clientNotifications;

+ (NSArray *)contentNotifications:(NSMutableArray *)notifications;

+ (BOOL)duplicateUpdateDetailsCall:(DNRequest *)request exchangeRequest:(NSMutableArray *)exchangeRequests;

@end
