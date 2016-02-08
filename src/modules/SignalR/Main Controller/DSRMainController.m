//
//  DSRMainController.m
//  SignalR
//
//  Created by Donky Networks on 06/08/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DSRMainController.h"
#import "DNLoggingController.h"
#import "DNDonkyNetworkDetails.h"
#import "DNDonkyCore.h"
#import "SRHubConnection.h"
#import "SRHubProxy.h"
#import "DNDeviceConnectivityController.h"
#import "DNQueueManager.h"

@interface DSRMainController ()
@property (nonatomic, strong) DNDeviceConnectivityController *deviceConnectivity;
@property (nonatomic, getter=isConnectionOpen) BOOL connectionOpen;
@property (nonatomic, strong) SRHubConnection *hubConnection;
@property (nonatomic, strong) SRHubProxy *signalRHubProxy;
@end

@implementation DSRMainController

+(DSRMainController *)sharedInstance
{
    static dispatch_once_t onceToken;
    static DSRMainController *sharedInstance = nil;

    dispatch_once(&onceToken, ^{
        sharedInstance = [[DSRMainController alloc] initPrivate];
    });

    return sharedInstance;
}

-(instancetype)init
{
    return [self initPrivate];
}

-(instancetype)initPrivate
{
    self  = [super init];

    if (self) {
        
    }

    return self;
}

- (void)start {

    if (![self deviceConnectivity]) {
        [self setDeviceConnectivity:[[DNDeviceConnectivityController alloc] init]];
    }

    if ([[self deviceConnectivity] hasValidConnection]) {

        DNModuleDefinition *signalRModule = [[DNModuleDefinition alloc] initWithName:@"MobileSignalR" version:@"1.0.0.0"];

        [[DNDonkyCore sharedInstance] registerModule:signalRModule];
        [[DNDonkyCore sharedInstance] registerService:@"DonkySignalRService" instance:self];

        if (![self hubConnection] && [DNDonkyNetworkDetails signalRURL] && [DNDonkyNetworkDetails accessToken]) {
            [self setHubConnection:[[SRHubConnection alloc] initWithURLString:[DNDonkyNetworkDetails signalRURL] queryString:@{@"access_token" : [DNDonkyNetworkDetails accessToken]} useDefault:NO]];
            [[self hubConnection] setDelegate:self];

            [self setSignalRHubProxy:[[self hubConnection] createHubProxy:@"NetworkHub"]];
            [[self signalRHubProxy] on:@"push" perform:self selector:@selector(serverNotificationsReceived:)];

            [[self hubConnection] start];
        }

        else if (![DNDonkyNetworkDetails signalRURL]) {
            DNErrorLog(@"Cannot start signalR. Don't have the URL.");
        }
        else {
            DNInfoLog(@"SignalR is already running...");
        }
    }
}

- (void)serverNotificationsReceived:(id)serverNotifications {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    dispatch_async(donky_network_signal_r_queue(), ^{
        __block NSMutableDictionary *responseBatches = [[NSMutableDictionary alloc] init];
        [serverNotifications enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            DNServerNotification *serverNotification = [[DNServerNotification alloc] initWithNotification:obj];
            NSMutableArray *batch = responseBatches[[serverNotification notificationType]] ?: [[NSMutableArray alloc] init];

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
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

- (void)stop {
    if ([self hubConnection]) {
        [[self hubConnection] stop];
        [self setHubConnection:nil];
        [self setConnectionOpen:NO];
    }
    else {
        DNInfoLog(@"No valid connection to close...");
    }
}

- (void)sendData:(id)data completion:(DNSignalRCompletionBlock)completionBlock {
    if ([self isConnectionOpen]) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

        dispatch_async(donky_network_signal_r_queue(), ^{
            NSMutableArray *combined = [[NSMutableArray alloc] init];

            if (data[@"clientNotifications"]) {
                [combined addObject:data[@"clientNotifications"]];
            }
            if (data[@"contentNotifications"]) {
                [combined addObject:data[@"contentNotifications"]];
            }

            if ([combined count]) {
                [[self signalRHubProxy] invoke:@"synchronise" withArgs:combined completionHandler:completionBlock];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            });
 
        });
    }
}

- (BOOL)signalRIsReady {
    return [self isConnectionOpen];
}

- (void)SRConnectionDidOpen:(id <SRConnectionInterface>)connection {
    DNInfoLog(@"SignalR connection did open");
    [self setConnectionOpen:YES];
}

- (void)SRConnectionWillReconnect:(id <SRConnectionInterface>)connection {
    DNInfoLog(@"SignalR connection will close");
}

- (void)SRConnectionDidReconnect:(id <SRConnectionInterface>)connection {
    DNInfoLog(@"SignalR connection did reconnect");
    [self setConnectionOpen:YES];
}

- (void)SRConnectionDidClose:(id <SRConnectionInterface>)connection {
    DNInfoLog(@"SignalR connection did close");
    [self setConnectionOpen:NO];
}

- (void)SRConnection:(id <SRConnectionInterface>)connection didReceiveError:(NSError *)error {
    DNErrorLog(@"SignalR Error: %@", [error localizedDescription]);
}

- (void)SRConnection:(id <SRConnectionInterface>)connection didChangeState:(connectionState)oldState newState:(connectionState)newState {

    switch (newState) {
        case connecting:
            DNInfoLog(@"SignalR connecting...");
            [self setConnectionOpen:NO];
            break;
        case connected:
            DNInfoLog(@"SignalR connecting...");
            [self setConnectionOpen:YES];
            break;
        case reconnecting:
            DNInfoLog(@"SignalR connecting...");
            [self setConnectionOpen:NO];
            break;
        case disconnected: {
            DNInfoLog(@"SignalR disconected... attempting to reconnect...");
            [self stop];
            [self start];
        }
            break;
    }
}

- (void)SRConnectionDidSlow:(id <SRConnectionInterface>)connection {
    DNInfoLog(@"Signal R did Slow");
}

@end
