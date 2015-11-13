//
//  AppDelegate.m
//  RichInboxTabs
//
//  Created by Chris Watson on 23/06/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import "AppDelegate.h"
#import "DCAAnalyticsController.h"
#import "DRIMainController.h"
#import "DNDonkyCore.h"
#import "DNNotificationController.h"
#import "SecondViewController.h"
#import "DNUserDetails.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //Start Donky:
    //Analytics:
    [[DCAAnalyticsController sharedInstance] start];
        
    //Rich Inbox:
    [[DRIMainController sharedInstance] start];
    
    [[DNDonkyCore sharedInstance] initialiseWithAPIKey:@"xbtdB9hdea4mJ5AKbKyGV7QA+ZtodIcG18zECr62ZFKjgHjNbPMR9rpUPCfpbYKjNS1FL7OAncGdnee3zw"];
    
    ///End Donky
    
    //Additional views:
    SecondViewController *secondView = [[SecondViewController alloc] init];
    UINavigationController *secondViewNavigationController = [[UINavigationController alloc] initWithRootViewController:secondView];
    
    UIViewController *richInboxView = [[DRIMainController sharedInstance] universalRichInboxViewController];
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[richInboxView, secondViewNavigationController];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [DNNotificationController registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    [DNNotificationController didReceiveNotification:userInfo handleActionIdentifier:nil completionHandler:^(NSString *string) {
        completionHandler(UIBackgroundFetchResultNewData);
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
