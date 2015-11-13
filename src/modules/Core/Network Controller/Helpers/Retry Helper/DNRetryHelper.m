//
//  DNRetryHelper.m
//  Core Container
//
//  Created by Donky Networks on 21/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "AFURLConnectionOperation.h"
#import "DNRetryHelper.h"
#import "DNConfigurationController.h"
#import "DNRetryObject.h"
#import "DNLoggingController.h"

static NSString *const DNRetryPolicy = @"DeviceCommsConnectionRetrySchedule";

@interface DNRetryHelper ()
@property(nonatomic, strong) NSMutableArray *retriedRequests;
@property(nonatomic, strong) NSArray *retryComponents;
@end

@implementation DNRetryHelper

- (instancetype) init {

    self = [super init];

    if (self) {
        NSString *retryPolicy = [DNConfigurationController objectFromConfiguration:DNRetryPolicy] ? : @"5,2|30,2|60,1|120,1|300,9|600,6|900,*";
        //Get components:
        [self setRetryComponents:[retryPolicy componentsSeparatedByString:@"|"]];
        [self setRetriedRequests:[[NSMutableArray alloc] init]];
    }

    return self;
}


- (void)retryRequest:(DNRequest *)request task:(NSURLSessionDataTask *)task {

    __block DNRetryObject *retryObject = nil;

    //Check if this request has already been retried:
    [[self retriedRequests] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DNRetryObject *retriedRequest = obj;
        if ([[retriedRequest request] parameters]) {
            if ([[retriedRequest request] parameters] == [request parameters]) {
                retryObject = retriedRequest;
                *stop = YES;
            }
        }
        else if ([[retriedRequest request] successBlock] == [request successBlock]) {
            retryObject = retriedRequest;
            *stop = YES;
        }
    }];

    if (!retryObject) {
        retryObject = [[DNRetryObject alloc] initWithRequest:request];
        [[self retriedRequests] addObject:retryObject];
    }

    if (retryObject) {
        [self applyRetry:retryObject];
    }
}

- (void)applyRetry:(DNRetryObject *)object {
    //Get retry string:
    NSString *retryString = nil;
    NSUInteger index = [object sectionRetries];
    if (index < 10) {
        retryString = [self retryComponents][index];
    }
    else {
        retryString = [[self retryComponents] lastObject];
    }

    if (retryString) {
        NSArray *retryComponents = [retryString componentsSeparatedByString:@","];

        if ([[retryComponents lastObject] integerValue] <= [object numberOfRetries]) {
            [object incrementRetryCount];
            [object incrementSection];
            [self applyRetry:object];
            return;
        }

        DNInfoLog(@"request failed %@... Applying retry policy %@", [[object request] route], retryString);
        NSInteger retryTime = [[retryComponents firstObject] integerValue];
        [self performSelector:@selector(retryEvent:) withObject:object afterDelay:retryTime];

        //Check if retry greater than
        [object incrementRetryCount];
    }
}

- (void)retryEvent:(DNRetryObject *)retryEvent {
    DNRequest *request = [retryEvent request];
    [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:[request isSecure] route:[request route] httpMethod:[request method] parameters:[request parameters] success:^(NSURLSessionDataTask *task, id responseData) {
        [[self retriedRequests] removeObject:retryEvent];
        if ([request successBlock]) {
            [request successBlock];
        }
    } failure:[request failureBlock]];
}

@end
