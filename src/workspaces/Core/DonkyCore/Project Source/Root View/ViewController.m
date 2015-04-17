//
//  ViewController.m
//  NAAS Core SDK Container
//
//  Created by Chris Watson on 16/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "ViewController.h"
#import "DNLoggingController.h"
#import "DNAccountController.h"
#import "DNNetworkController.h"
#import "DNDonkyCore.h"
#import "DNNotificationController.h"
#import "DNContentNotification.h"
#import "DNConstants.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //Lets update to a known user:
    self.title = [[[DNAccountController registrationDetails] userDetails] userID];

    DNModuleDefinition *moduleDefinition = [[DNModuleDefinition alloc] initWitName:NSStringFromClass([self class]) version:@"1.0"];
    
    DNSubscription *subscription = [[DNSubscription alloc] initWithNotificationType:@"chessMove" handler:^(DNServerNotification *serverNotification) {
        DNInfoLog(@"Server %@", serverNotification);
    }];

    [[DNDonkyCore sharedInstance] subscribeToContentNotifications:moduleDefinition subscriptions:@[subscription]];
 
    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDNEventRegistration handler:^(DNLocalEvent *event) {
        self.title = [[[DNAccountController registrationDetails] userDetails] userID];
    }];    
}

- (void)chessMoveReceived:(DNServerNotification *)notification {
    NSLog(@"%@", notification);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sync:(id)sender {
    [[DNNetworkController sharedInstance] synchroniseSuccess:^(NSURLSessionDataTask *task, id responseData) {
        self.title = [[[DNAccountController registrationDetails] userDetails] userID];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {

    }];
}

- (IBAction)updateToKnownUser:(id)sender {
    if ([[[DNAccountController registrationDetails] userDetails] isAnonymous]) {
        DNUserDetails *user = [DNAccountController userID:@"tandom" displayName:@"Chris" emailAddress:@"chris.watson@dynmark.com" mobileNumber:@"07545804334" countryCode:@"GBR" firstName:nil lastName:nil avatarID:nil selectedTags:nil additionalProperties:nil];
        [DNAccountController updateUserDetails:user success:^(NSURLSessionDataTask *task, id responseData) {
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [error localizedDescription];
        }];
    }
}

- (IBAction)initialise:(id)sender {
    [[DNDonkyCore sharedInstance] initialiseWithAPIKey:@"vMBC8SHsILtV1g+UVnozZ0QmMKM4mcpNbNLfwUQnKq8P2z1XPMhhuHThwszJorUv32epCXMSjq3kwq0KM35w"];

    //Create a new known user:
    DNUserDetails *userDetails = [[DNUserDetails alloc] initWithUserID:@"UNIQUE_USER_ID" displayName:@"OPTIONAL" emailAddress:@"OPTIONAL" mobileNumber:@"OPTIONAL" countryCode:@"OPTIONAL" lastName:nil firstName:nil avatarID:nil selectedTags:nil additionalProperties:nil];
    //Create a new device details object:
    DNDeviceDetails *deviceDetails = [[DNDeviceDetails alloc] initWithDeviceType:@"iPhone" name:@"My iPhone" additionalProperties:nil];
    [[DNDonkyCore sharedInstance] initialiseWithAPIKey:@"YOUR_API_KEY" userDetails:userDetails deviceDetails:deviceDetails success:^(NSURLSessionDataTask *task, id responseData) {

    } failure:^(NSURLSessionDataTask *task, NSError *error) {

    }];
}

- (IBAction)reRegister:(id)sender {
    DNUserDetails *newDevice = [DNAccountController userID:@"chriswatom" displayName:@"Chris" emailAddress:@"chriswatson00@me.com" mobileNumber:@"07545804334" countryCode:@"GBR" firstName:nil lastName:nil avatarID:nil selectedTags:nil additionalProperties:nil];
    [DNAccountController replaceRegistrationDetailsWithUserDetails:newDevice deviceDetails:nil success:^(NSURLSessionDataTask *task, id responseData) {

    } failure:^(NSURLSessionDataTask *task, NSError *error) {

    }];
}

- (IBAction)updateRegistrationDetails:(id)sender {

    DNUserDetails *currentUser = [[DNUserDetails alloc] initWithUserID:@"newnew" displayName:@"New" emailAddress:@"chris@me.com" mobileNumber:nil countryCode:nil lastName:nil firstName:nil avatarID:nil selectedTags:nil additionalProperties:nil];
    DNDeviceDetails *current = [[DNDeviceDetails alloc] initWithDeviceType:@"iPhone Innit" name:@"ma fone" additionalProperties:nil];
    [DNAccountController updateRegistrationDetails:currentUser deviceDetails:current success:^(NSURLSessionDataTask *task, id responseData) {

    } failure:^(NSURLSessionDataTask *task, NSError *error) {

    }];
}

- (IBAction)reRegisterAnonymously:(id)sender {
    [DNAccountController replaceRegistrationDetailsWithUserDetails:nil deviceDetails:nil success:^(NSURLSessionDataTask *task, id responseData) {
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
    }];
}

- (IBAction)togglePushRegistration:(id)sender {

    BOOL enablePush = [sender tag] == 1;

    if (enablePush)
        [DNNotificationController registerForPushNotifications];
    else
        [DNNotificationController enablePush:NO];
}

- (void)loadColourDemo:(id)sender {
    
    
    
}

- (IBAction)sendCustomContent:(id)sender {
//    DNContentNotification *contentNotification = [[DNContentNotification alloc] initWithUsers:@[@"1dkhir"] customType:@"chessMove" data:@{@"kingMove" : @"A1 - B4"}];
//    [[DNNetworkController sharedInstance] queueContentNotifications:@[contentNotification]];

    DNModuleDefinition *moduleDefinition = [[DNModuleDefinition alloc] initWitName:NSStringFromClass([self class]) version:@"1.0"];
    DNSubscription *subscription = [[DNSubscription alloc] initWithNotificationType:@"unitTest1" handler:^(DNServerNotification *serverNotification) {
        NSLog(@"%@", serverNotification);
    }];
    DNSubscription *subscription2 = [[DNSubscription alloc] initWithNotificationType:@"unitTest2" handler:^(DNServerNotification *serverNotification) {
        NSLog(@"%@", serverNotification);
    }];
    DNSubscription *subscription3 = [[DNSubscription alloc] initWithNotificationType:@"unitTest3" handler:^(DNServerNotification *serverNotification) {
        NSLog(@"%@", serverNotification);
    }];
    DNSubscription *subscription4 = [[DNSubscription alloc] initWithNotificationType:@"unitTest4" handler:^(DNServerNotification *serverNotification) {
        NSLog(@"%@", serverNotification);
    }];
    [[DNDonkyCore sharedInstance] subscribeToContentNotifications:moduleDefinition subscriptions:@[subscription, subscription2, subscription3, subscription4]];

    NSString *userID = @"UnitTest_737437070";
    
    DNContentNotification *contentNotification  = [[DNContentNotification alloc] initWithUsers:@[userID] customType:@"unitTest1" data:@{@"kingMove" : @"A1 - B4"}];
    DNContentNotification *contentNotification2 = [[DNContentNotification alloc] initWithUsers:@[userID] customType:@"unitTest2" data:@{@"kingMove" : @"A1 - B4"}];
    DNContentNotification *contentNotification3 = [[DNContentNotification alloc] initWithUsers:@[userID] customType:@"unitTest3" data:@{@"kingMove" : @"A1 - B4"}];
    
    DNContentNotification *contentNotification4 = [[DNContentNotification alloc] initWithUsers:@[userID] customType:@"unitTest4" data:@{@"kingMove" : @"A1 - B4"}];
    
    [[DNNetworkController sharedInstance] queueContentNotifications:@[contentNotification, contentNotification2, contentNotification3, contentNotification4]];

    [[DNNetworkController sharedInstance] synchronise];

}

@end
