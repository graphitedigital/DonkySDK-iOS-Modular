//
//  AppDelegate.m
//  DonkyCore
//
//  Created by Chris Watson on 30/03/2015.
//  Copyright (c) 2015 Chris Watson. All rights reserved.
//

#import "AppDelegate.h"
#import "DNNotificationController.h"
#import "DNDonkyCore.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[DNDonkyCore sharedInstance] initialiseWithAPIKey:@"vMBC8SHsILtV1g+UVnozZ0QmMKM4mcpNbNLfwUQnKq8P2z1XPMhhuHThwszJorUv32epCXMSjq3kwq0KM35w"];
    
    [application setApplicationIconBadgeNumber:0];

    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:@"APPDELEGATE" handler:^(DNLocalEvent *event) {
       //DO SOMETHING HERE:
        if ([[event data] isKindOfClass:[NSDictionary class]])
            NSLog(@"%@", [event data][@"Key"]);
    }];
    
    
    DNLocalEvent *appDelegate = [[DNLocalEvent alloc] initWithEventType:@"APPDELEGATE" publisher:NSStringFromClass([self class]) timeStamp:[NSDate date] data:@[@{@"Key" : @"this is a value"}]];
    [[DNDonkyCore sharedInstance] publishEvent:appDelegate];
    

    // Override point for customization after application launch.
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [DNNotificationController registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [DNNotificationController didReceiveNotification:userInfo handleActionIdentifier:nil completionHandler:^(NSString *string) {

    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    [DNNotificationController didReceiveNotification:userInfo handleActionIdentifier:nil completionHandler:^(NSString *string) {
        completionHandler(UIBackgroundFetchResultNewData);
    }];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    [DNNotificationController didReceiveNotification:userInfo handleActionIdentifier:identifier completionHandler:^(NSString *string) {
        completionHandler();
    }];
}


@end
