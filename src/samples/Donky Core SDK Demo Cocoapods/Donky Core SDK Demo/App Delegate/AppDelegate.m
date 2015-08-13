//
//  AppDelegate.m
//  Donky Core SDK Demo
//
//  Created by Chris Watson on 26/07/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "DNDonkyCore.h"
#import "DCAAnalyticsController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    //Start analytics (optional)
    [[DCAAnalyticsController sharedInstance] start];

    /*
    //Remove this comment block to initialise anonymously.
    [[DNDonkyCore sharedInstance] initialiseWithAPIKey:@"API-KEY"];
    */

    /*
    //Remove this comment block to initialise with a known user.
    //Create a new user and populate with details. Country code is optional is NO mobile number is provided. If a
    //mobile number is provided then a country code is mandatory. Failing to provide a country code that matches the
    //mobile number will result in a server validation error.
    DNUserDetails *userDetails = [[DNUserDetails alloc] initWithUserID:@""
                                                           displayName:@""
                                                          emailAddress:@""
                                                          mobileNumber:@""
                                                           countryCode:@""
                                                             firstName:@""
                                                              lastName:@""
                                                              avatarID:@""
                                                          selectedTags:@[]
                                                  additionalProperties:@{}];

    //Initialise Donky with API key.
    [[DNDonkyCore sharedInstance] initialiseWithAPIKey:@"API-KEY" userDetails:userDetails success:^(NSURLSessionDataTask *task, id responseData) {
        NSLog(@"Successfully Initialised with user...");
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
    */

    return YES;
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
