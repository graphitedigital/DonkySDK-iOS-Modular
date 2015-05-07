//
//  DNDeviceConnectivityController.m
//  Core Container
//
//  Created by Chris Watson on 17/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNDeviceConnectivityController.h"
#import "AFHTTPRequestOperationManager.h"
#import "DNLoggingController.h"
#import "DNConstants.h"
#import "DNDonkyCore.h"

@interface DNDeviceConnectivityController ()
@property(nonatomic, readwrite, getter=hasValidConnection) BOOL validConnection;
@property(nonatomic, strong) NSMutableArray *failedRequest;
@property(nonatomic) NSInteger status;
@end

@implementation DNDeviceConnectivityController

- (instancetype) init {

    self = [super init];

    if (self) {

        [self setFailedRequest:[[NSMutableArray alloc] init]];

        [self checkForConnections];

        //Check for connections:
        NSURL *baseURL = [NSURL URLWithString:@"http://www.apple.com"];
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
        //We just use Reachability to get status updates around when the network condition changes i.e. moving from WiFi to Cellular etc...
        
        __weak  DNDeviceConnectivityController *weakSelf = self;
        [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            DNInfoLog(@"Network status has changed to: %ld\nChecking connection validity...", (long)status);
            weakSelf.status = status;
            [self checkForConnections];
        }];
        [manager.reachabilityManager startMonitoring];

    }

    return self;
}

- (void)checkForConnections {

    self.validConnection = [self appleContactable];

    if (!self.hasValidConnection)
        self.validConnection = [self googleContactable];

    if (!self.hasValidConnection)
        self.validConnection = [self facebookContactable];

    //Publish connection event: Dictionary containing a BOOL representing the connection state:
    DNLocalEvent *connectionEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventNetworkStateChanged 
                                                                  publisher:NSStringFromClass([self class]) 
                                                                  timeStamp:[NSDate date] 
                                                                       data:@{@"IsConnected" : @(self.hasValidConnection), @"ConnectionType" : @(self.status)}];
    [[DNDonkyCore sharedInstance] publishEvent:connectionEvent];

    if ([self hasValidConnection] && [[self failedRequest] count]) {
        [[self failedRequest] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            DNRequest *originalRequest = obj;
            DNInfoLog(@"Processing request that failed due to invalid internet connection: %@", [originalRequest route]);
            [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:[originalRequest isSecure]
                                                                          route:[originalRequest route]
                                                                     httpMethod:[originalRequest method]
                                                                     parameters:[originalRequest parameters]
                                                                        success:[originalRequest successBlock]
                                                                        failure:[originalRequest failureBlock]];
        }];

        //Remove the objects
        [[self failedRequest] removeAllObjects];
        //Do a sync too:
        [[DNNetworkController sharedInstance] synchronise];
    }
}

- (void)addFailedRequestToQueue:(DNRequest *)request {
    __block NSMutableArray *multipleSyncs = [[NSMutableArray alloc] init];
    //We want to trim out duplicate synchronise calls:
    [[self failedRequest] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DNRequest *savedRequest = obj;
        if (([[savedRequest route] isEqualToString:kDNNetworkAuthentication] && [[request route] isEqualToString:kDNNetworkAuthentication]) ||
                ([[savedRequest route] isEqualToString:kDNNetworkRegistration] && [[request route] isEqualToString:kDNNetworkRegistration]))
            [multipleSyncs addObject:savedRequest];
    }];
    [[self failedRequest] addObject:request];
    [[self failedRequest] removeObjectsInArray:multipleSyncs];

}

- (BOOL)facebookContactable {
    NSURL *url= [NSURL URLWithString:@"http://www.facebook.com"];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"HEAD"];
    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: NULL];
    return [response statusCode] == 200;
}

- (BOOL)appleContactable {
    NSURL *url= [NSURL URLWithString:@"http://www.apple.com"];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"HEAD"];
    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: NULL];
    return [response statusCode] == 200;
}

- (BOOL)googleContactable {
    NSURL *url= [NSURL URLWithString:@"http://www.google.com"];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"HEAD"];
    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: NULL];
    return [response statusCode] == 200;
}

@end
