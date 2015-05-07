//
//  AppDelegate.m
//  Donky-Core-Tests
//
//  Created by Chris Watson on 20/04/2015.
//  Copyright (c) 2015 Chris Watson. All rights reserved.
//

#import "AppDelegate.h"
#import "DNNotificationController.h"
#import "DCAAnalyticsController.h"
#import "DNDonkyCore.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
    [[DCAAnalyticsController sharedInstance] start];
    
    [[DNDonkyCore sharedInstance] initialiseWithAPIKey:@"ye7MDvQQVUKwR2DgMhHC89gy76HOFVtYq3PLKiOyYvDyQwFKzusUCBAphwDvMNGvlDfK2WhRFo41sF0fD4sf1Q"];
    
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

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
