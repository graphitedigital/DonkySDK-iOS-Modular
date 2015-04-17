//
//  DonkyCoreTests.m
//  DonkyCoreTests
//
//  Created by Chris Watson on 30/03/2015.
//  Copyright (c) 2015 Chris Watson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DNDonkyNetworkDetails.h"
#import "DNDeviceUser.h"
#import "DNDataController.h"
#import "NSManagedObject+DNHelper.h"
#import "DNDonkyCore.h"
#import "DNAccountController.h"
#import "DNConfigurationController.h"
#import "DNConstants.h"
#import "DNContentNotification.h"
#import "DNNetworkController.h"
#import "DNUserAuthentication.h"
#import "DNLoggingController.h"
#import "DNNetwork+Localization.h"
#import "UIViewController+DNRootViewController.h"
#import "NSMutableDictionary+DNDictionary.h"
#import "DNNotificationController.h"
#import "DNNetworkHelper.h"
#import "DNRetryHelper.h"
#import "DNRetryObject.h"
#import "DNRequest.h"
#import "DNDeviceConnectivityController.h"
#import "DNErrorController.h"

@interface DonkyCoreTests : XCTestCase

@end

@implementation DonkyCoreTests

- (void)setUp {
    
    [super setUp];
    
    [DNDonkyNetworkDetails saveDeviceID:nil];
    [DNDonkyNetworkDetails saveAccessToken:nil];
    [DNDonkyNetworkDetails saveDeviceSecret:nil];
    [DNDonkyNetworkDetails saveNetworkID:nil];
    
    //Delete user:
    DNDeviceUser *user = [DNDeviceUser fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"isDeviceUser == YES"] withContext:[[DNDataController sharedInstance] mainContext]];
    if (user)
        [[[DNDataController sharedInstance] mainContext] deleteObject:user];
    
    [[DNDataController sharedInstance] saveAllData];
    
    __block BOOL waitingForBlock = YES;
    
    // Put setup code here. This method is called before the invocation of each test method in the class.init
    [[DNDonkyCore sharedInstance] initialiseWithAPIKey:@"vMBC8SHsILtV1g+UVnozZ0QmMKM4mcpNbNLfwUQnKq8P2z1XPMhhuHThwszJorUv32epCXMSjq3kwq0KM35w" userDetails:[[DNAccountController registrationDetails] userDetails] success:^(NSURLSessionDataTask *task, id responseData) {
        if ([DNDonkyNetworkDetails networkId])
            waitingForBlock = NO;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        waitingForBlock = NO;
    }];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    
    while (waitingForBlock){
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSubscribeToAndPublishEvent {

    DNLocalEventHandler handler = ^(DNLocalEvent *event) {
        XCTAssertNotNil(event);
    };

    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:@"Test Event" handler:handler];
    
    DNLocalEvent *localEvent = [[DNLocalEvent alloc] initWithEventType:@"Test Event" publisher:NSStringFromClass([self class]) timeStamp:[NSDate date] data:@{}];
    
    [[DNDonkyCore sharedInstance] publishEvent:localEvent];
    
    [[DNDonkyCore sharedInstance] unSubscribeToLocalEvent:@"Test Event" handler:handler];
}

- (void)testUnsubscribeLog {
        
    DNLocalEventHandler handler = ^(DNLocalEvent *event) {
        XCTFail(@"should not be here");
    };
    
    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:@"Test Event" handler:handler];
    
    DNLocalEvent *localEvent = [[DNLocalEvent alloc] initWithEventType:@"Test Event" publisher:NSStringFromClass([self class]) timeStamp:[NSDate date] data:@{}];
    
    [[DNDonkyCore sharedInstance] unSubscribeToLocalEvent:@"Test Event" handler:handler];
    
    [[DNDonkyCore sharedInstance] publishEvent:localEvent];
}

- (void)testUnregisterService {
    [[DNDonkyCore sharedInstance] registerService:@"Core Service" instance:self];
    [[DNDonkyCore sharedInstance] unRegisterService:@"Core Service"];
    XCTAssertNil([[DNDonkyCore sharedInstance] serviceForType:@"Core Service"]);
}

- (void)testRegisterService {
    [[DNDonkyCore sharedInstance] registerService:@"Unit Test" instance:self];
    XCTAssertNotNil([[DNDonkyCore sharedInstance] serviceForType:@"Unit Test"]);
    [[DNDonkyCore sharedInstance] unRegisterService:@"Unit Test"];
}

- (void)testGetModule {
    DNModuleDefinition *module = [[DNModuleDefinition alloc]initWitName:@"Unit Tests" version:@"1.0.2.0"];
    [[DNDonkyCore sharedInstance] registerModule:module];
    XCTAssertTrue([[DNDonkyCore sharedInstance] isModuleRegistered:@"Unit Tests" moduleVersion:@"1.0.0.0"]);
}

- (void)testGetModuleWithLowerVersion {
    DNModuleDefinition *module = [[DNModuleDefinition alloc]initWitName:@"Unit Tests" version:@"1.0.2.0"];
    [[DNDonkyCore sharedInstance] registerModule:module];
    XCTAssertFalse([[DNDonkyCore sharedInstance] isModuleRegistered:@"Unit Tests" moduleVersion:@"2.0.0.0"]);
}

- (void)testGetModuleWithPaddedVersion {
    DNModuleDefinition *module = [[DNModuleDefinition alloc]initWitName:@"Unit Tests" version:@"1.0.2.0"];
    [[DNDonkyCore sharedInstance] registerModule:module];
    XCTAssertFalse([[DNDonkyCore sharedInstance] isModuleRegistered:@"Unit Tests" moduleVersion:@"2.0"]);
}

- (void)testSearchAllModules {
    DNModuleDefinition *module = [[DNModuleDefinition alloc]initWitName:@"Unit Tests" version:@"1.0.2.0"];
    [[DNDonkyCore sharedInstance] registerModule:module];
    __block BOOL matchFound = NO;
    [[[DNDonkyCore sharedInstance] allRegisteredModules] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DNModuleDefinition *module = obj;
        if ([[module name] isEqualToString:@"Unit Tests"])
            matchFound = YES;
    }];
    XCTAssertTrue(matchFound);
}

- (void)testModuleNotFound {
    __block BOOL matchFound = NO;
    [[[DNDonkyCore sharedInstance] allRegisteredModules] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DNModuleDefinition *module = obj;
        if ([[module name] isEqualToString:@"Non Existent"])
            matchFound = YES;
    }];
    XCTAssertFalse(matchFound);
}

- (void)testAllModules {
    XCTAssertNotNil([[DNDonkyCore sharedInstance] allRegisteredModules], @"All Modules array retrieved");
}

- (void)testNilEventHandler {
    DNLocalEvent *localEvent = [[DNLocalEvent alloc] initWithEventType:@"Test Event" publisher:nil timeStamp:nil data:nil];

    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:@"Test Event" handler:nil];

    [[DNDonkyCore sharedInstance] publishEvent:localEvent];
}

- (void)testRegsiterLocalEvent {
    DNLocalEvent *localEvent = [[DNLocalEvent alloc] initWithEventType:@"Test Event" publisher:nil timeStamp:nil data:nil];
    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:@"Test Event" handler:^(DNLocalEvent *event) {
        XCTAssertNotNil(event);
    }];
    
    [[DNDonkyCore sharedInstance] publishEvent:localEvent];
}

- (void)testUnregisterLocalEvent {
   
    DNLocalEventHandler handler = ^(DNLocalEvent *event) {
        XCTFail(@"Should not get here");
    };
    
    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:@"Test Event" handler:handler];
    
    DNLocalEvent *localEvent = [[DNLocalEvent alloc] initWithEventType:@"Test Event" publisher:NSStringFromClass([self class]) timeStamp:[NSDate date] data:@{}];
    [[DNDonkyCore sharedInstance] unSubscribeToLocalEvent:@"Test Event" handler:handler];
    
    [[DNDonkyCore sharedInstance] publishEvent:localEvent];
}

- (void)testDebugLog {
    DNModuleDefinition *moduleDefinition = [[DNModuleDefinition alloc] initWitName:NSStringFromClass([self class]) version:@"1.0.0.0"];
    
    
    DNSubscription *subscription = [[DNSubscription alloc] initWithNotificationType:kDNDonkyNotificationTransmitDebugLog handler:^(id data) {
        XCTAssertNotNil(data, @"Server notification was received");
    }];
    [subscription setAutoAcknowledge:YES];
    [[DNDonkyCore sharedInstance] subscribeToDonkyNotifications:moduleDefinition subscriptions:@[subscription]];
    
    NSDictionary *transmitDebugLog = @{@"createdOn" : @"2015-03-21T15:39:07.8033541Z", @"data" : @{}, @"id" : @"8ca1f11b-6d02-449f-bd5c-6c5369c58323", @"type" : @"TransmitDebugLog"};
    [[DNDonkyCore sharedInstance] notificationReceived:[[DNServerNotification alloc] initWithNotification:transmitDebugLog]];
    [[DNDonkyCore sharedInstance] unSubscribeToDonkyNotifications:moduleDefinition subscriptions:@[subscription]];
}

- (void)testConfigurationChange {
    [DNConfigurationController saveConfigurationObject:@(0) forKey:@"AlwaysSubmitErrors"];
    XCTAssertFalse([[DNConfigurationController objectFromConfiguration:@"AlwaysSubmitErrors"] boolValue]);
}

- (void)testContentNotificationsIntegration {
    __block BOOL waitingForBlock = YES;
    
    //Now trigger:
    NSString *userID = [[[DNAccountController registrationDetails] userDetails] userID];
    if (userID) {
        DNContentNotification *contentNotification = [[DNContentNotification alloc] initWithUsers:@[userID] customType:@"unitTest1" data:@{@"kingMove" : @"A1 - B4"}];
        DNContentNotification *contentNotification2 = [[DNContentNotification alloc] initWithUsers:@[userID] customType:@"unitTest2" data:@{@"kingMove" : @"A1 - B4"}];
        DNContentNotification *contentNotification3 = [[DNContentNotification alloc] initWithUsers:@[userID] customType:@"unitTest3" data:@{@"kingMove" : @"A1 - B4"}];
        DNContentNotification *contentNotification4 = [[DNContentNotification alloc] initWithUsers:@[userID] customType:@"unitTest4" data:@{@"kingMove" : @"A1 - B4"}];
        
        [[DNNetworkController sharedInstance] sendContentNotifications:@[contentNotification, contentNotification2, contentNotification3, contentNotification4] success:^(NSURLSessionDataTask *task, id responseData) {
            waitingForBlock = NO;
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            XCTFail(@"Failed: %@", [error localizedDescription]);
        }];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        
        while(waitingForBlock){
            [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
        }
    }
    
    else
        XCTFail(@"No user ID");
}

- (void)testUnsubscribeFromNotification {
    DNModuleDefinition *moduleDefinition = [[DNModuleDefinition alloc] initWitName:NSStringFromClass([self class]) version:@"1.0"];
    DNSubscription *subscription = [[DNSubscription alloc] initWithNotificationType:@"unitTest1" handler:^(DNServerNotification *serverNotification) {
    }];
    [[DNDonkyCore sharedInstance] subscribeToContentNotifications:moduleDefinition subscriptions:@[subscription]];
    [[DNDonkyCore sharedInstance] unSubscribeToContentNotifications:moduleDefinition subsciptions:@[subscription]];
}

- (void)testUnsubscribeNonExisting {
    DNModuleDefinition *moduleDefinition = [[DNModuleDefinition alloc] initWitName:NSStringFromClass([self class]) version:@"1.0"];
    DNSubscription *subscription = [[DNSubscription alloc] initWithNotificationType:@"Non Existing Unit Test" handler:^(DNServerNotification *serverNotification) {
    }];
    [[DNDonkyCore sharedInstance] unSubscribeToContentNotifications:moduleDefinition subsciptions:@[subscription]];
}

- (void)testUnsubscribeNonExistingAndSend {
    DNModuleDefinition *moduleDefinition = [[DNModuleDefinition alloc] initWitName:NSStringFromClass([self class]) version:@"1.0"];
    DNSubscription *subscription = [[DNSubscription alloc] initWithNotificationType:@"Non Existing Unit Test" handler:^(DNServerNotification *serverNotification) {
        XCTFail(@"Should not have received notification");
    }];

    [[DNDonkyCore sharedInstance] unSubscribeToContentNotifications:moduleDefinition subsciptions:@[subscription]];
    
    NSDictionary *transmitDebugLog = @{@"createdOn" : @"2015-03-21T15:39:07.8033541Z", @"data" : @{}, @"id" : @"8ca1f11b-6d02-449f-bd5c-6c5369c58323", @"type" : @"Non Existing Unit Test"};
    [[DNDonkyCore sharedInstance] notificationReceived:[[DNServerNotification alloc] initWithNotification:transmitDebugLog]];
}

- (void)testMultipleModuleSubscriptions {
    __block BOOL waitingForBlock = YES;
    
    __block NSInteger done = 0;
    
    DNModuleDefinition *moduleDefinition = [[DNModuleDefinition alloc] initWitName:NSStringFromClass([self class]) version:@"1.0"];
    DNSubscription *subscription = [[DNSubscription alloc] initWithNotificationType:@"unitTest1" handler:^(DNServerNotification *serverNotification) {
        done ++;
        if (done == 4)
            waitingForBlock = NO;
    }];
    DNSubscription *subscription2 = [[DNSubscription alloc] initWithNotificationType:@"unitTest2" handler:^(DNServerNotification *serverNotification) {
        done ++;
        if (done == 4)
            waitingForBlock = NO;
    }];
    
    DNModuleDefinition *moduleDefinition2 = [[DNModuleDefinition alloc] initWitName:@"Second Test" version:@"1.0"];
    
    DNSubscription *subscription3 = [[DNSubscription alloc] initWithNotificationType:@"unitTest1" handler:^(DNServerNotification *serverNotification) {
        done ++;
        if (done == 4)
            waitingForBlock = NO;
    }];
    DNSubscription *subscription4 = [[DNSubscription alloc] initWithNotificationType:@"unitTest2" handler:^(DNServerNotification *serverNotification) {
        done ++;
        if (done == 4)
            waitingForBlock = NO;
    }];
    
    [[DNDonkyCore sharedInstance] subscribeToContentNotifications:moduleDefinition subscriptions:@[subscription, subscription2]];
    
    [[DNDonkyCore sharedInstance] subscribeToContentNotifications:moduleDefinition2 subscriptions:@[subscription3, subscription4]];
    
    NSDictionary *transmitDebugLog = @{@"createdOn" : @"2015-03-21T15:39:07.8033541Z", @"data" : @{@"customType" : @"unitTest1"}, @"id" : @"8ca1f11b-6d02-449f-bd5c-6c5369c58323", @"type" : @"Custom"};
    [[DNDonkyCore sharedInstance] notificationReceived:[[DNServerNotification alloc] initWithNotification:transmitDebugLog]];
    
    NSDictionary *transmitDebugLog2 = @{@"createdOn" : @"2015-03-21T15:39:07.8033541Z", @"data" : @{@"customType" : @"unitTest2"}, @"id" : @"8ca1f11b-6d02-449f-bd5c-6c5369c58323", @"type" : @"Custom"};
    [[DNDonkyCore sharedInstance] notificationReceived:[[DNServerNotification alloc] initWithNotification:transmitDebugLog2]];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    
    while(waitingForBlock){
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }
    
    if (!waitingForBlock)
        XCTAssertTrue(done == 4);
}

- (void)testContentNotificationWithDictionaryIntegration {
    __block BOOL waitingForBlock = YES;
    [self measureBlock:^{
        DNContentNotification *contentNotification = [[DNContentNotification alloc] initWithUsers:@[@"1de21h"] customType:@"chessMove" data:@{@"kingMove" : @"A1 - B4"}];
        [[DNNetworkController sharedInstance] sendContentNotifications:@[contentNotification] success:^(NSURLSessionDataTask *task, id responseData) {
            XCTAssertNil(responseData);
            waitingForBlock = NO;
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            XCTFail(@"Error: %@", [error localizedDescription]);
            waitingForBlock = NO;
        }];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        
        while(waitingForBlock){
            [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
        }
    }];
}

- (void)testContentNotificationWithArrayIntegration {
    __block BOOL waitingForBlock = YES;
    [self measureBlock:^{
        DNContentNotification *contentNotification = [[DNContentNotification alloc] initWithUsers:@[@"1de21h"] customType:@"chessMove" data:@[@"KingMove", @"A1-A4"]];
        [[DNNetworkController sharedInstance] sendContentNotifications:@[contentNotification] success:^(NSURLSessionDataTask *task, id responseData) {
            XCTAssertNil(responseData);
            waitingForBlock = NO;
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            XCTFail(@"Error: %@", [error localizedDescription]);
            waitingForBlock = NO;
        }];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        
        while(waitingForBlock){
            [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
        }
    }];
}

- (void)testSubscribeToOutboundNotification {
    
    DNModuleDefinition *moduleDefinition = [[DNModuleDefinition alloc] initWitName:NSStringFromClass([self class]) version:@"1.0"];
    DNSubscription *subscription = [[DNSubscription alloc] initWithNotificationType:@"OutBoundTest" handler:^(id data) {
        XCTAssertNotNil(data);
    }];
    
    [[DNDonkyCore sharedInstance] subscribeToOutboundNotifications:moduleDefinition subscriptions:@[subscription]];
    
    [[DNDonkyCore sharedInstance] publishOutboundNotification:@"OutBoundTest" data:@{}];
}

- (void)testSubscribeToOutboundNotificationNetwork {
    
    DNModuleDefinition *moduleDefinition = [[DNModuleDefinition alloc] initWitName:NSStringFromClass([self class]) version:@"1.0"];
    DNSubscription *subscription = [[DNSubscription alloc] initWithNotificationType:@"OutBoundTest" handler:^(id data) {
        XCTAssertNotNil(data);
    }];
    
    [[DNDonkyCore sharedInstance] subscribeToOutboundNotifications:moduleDefinition subscriptions:@[subscription]];

    DNContentNotification *contentNotification = [[DNContentNotification alloc] initWithUsers:@[@"1de21h"] customType:@"chessMove" data:@{@"kingMove" : @"A1 - B4"}];
    
    [[DNNetworkController sharedInstance] sendContentNotifications:@[contentNotification] success:nil failure:nil];
}

- (void)testUnsubscribeToOutboundNotification {
    DNModuleDefinition *moduleDefinition = [[DNModuleDefinition alloc] initWitName:NSStringFromClass([self class]) version:@"1.0"];
    DNSubscription *subscription = [[DNSubscription alloc] initWithNotificationType:@"OutBoundTestFail" handler:^(DNServerNotification *serverNotification) {
        XCTFail(@"Should not be here");
    }];
    
    [[DNDonkyCore sharedInstance] subscribeToOutboundNotifications:moduleDefinition subscriptions:@[subscription]];
    
    DNContentNotification *test = [[DNContentNotification alloc] initWithUsers:@[@"test"] customType:@"OutBoundTestFail" data:@{}];
    
    [[DNNetworkController sharedInstance] queueContentNotifications:@[test]];
    
    [[DNDonkyCore sharedInstance] unSubscribeToOutboundNotifications:moduleDefinition subscriptions:@[subscription]];
    
    [[DNNetworkController sharedInstance] synchronise];
}

- (void)testMissingAPIKeyIntegration {
    __block BOOL waitingForBlock = YES;
    [[DNDonkyCore sharedInstance] initialiseWithAPIKey:nil userDetails:nil deviceDetails:nil success:^(NSURLSessionDataTask *task, id responseData) {
        XCTFail(@"Succeeded when it shouldn't have");
        waitingForBlock = NO;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTAssertNotNil(error);
        waitingForBlock = NO;
    }];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    
    while(waitingForBlock){
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }
}

- (void)testNilUserIntegration {
    __block BOOL waitingForBlock = YES;
    
    [DNDonkyNetworkDetails saveDeviceID:nil];
    [DNDonkyNetworkDetails saveAccessToken:nil];
    [DNDonkyNetworkDetails saveDeviceSecret:nil];
    [DNDonkyNetworkDetails saveNetworkID:nil];
    
    //Delete user:
    DNDeviceUser *user = [DNDeviceUser fetchSingleObjectWithPredicate:[NSPredicate predicateWithFormat:@"isDeviceUser == YES"] withContext:[[DNDataController sharedInstance] mainContext]];
    if (user)
        [[[DNDataController sharedInstance] mainContext] deleteObject:user];
    
    [[DNDataController sharedInstance] saveAllData];
    
    
    [[DNDonkyCore sharedInstance] initialiseWithAPIKey:@"vMBC8SHsILtV1g+UVnozZ0QmMKM4mcpNbNLfwUQnKq8P2z1XPMhhuHThwszJorUv32epCXMSjq3kwq0KM35w" userDetails:nil deviceDetails:nil success:^(NSURLSessionDataTask *task, id responseData) {
        XCTFail(@"Succeeded when it shouldn't have");
        waitingForBlock = NO;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
        XCTAssertNotNil(error);
        waitingForBlock = NO;
    }];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    
    while(waitingForBlock){
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }
}

- (void)testAccountRefreshAccessTokenIntegration {
    __block BOOL waitingForBlock = YES;
    
    [DNDonkyNetworkDetails saveTokenExpiry:nil];
    [DNAccountController refreshAccessTokenSuccess:^(NSURLSessionDataTask *task, id responseData) {
        XCTAssertNotNil(responseData);
        waitingForBlock = NO;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTFail(@"Access token refresh failed");
        waitingForBlock = NO;
    }];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    
    while(waitingForBlock){
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }
}

- (void)testAccountRefreshAccessTokenNilIntegration {
    
    __block BOOL waitingForBlock = YES;
    
    [DNDonkyNetworkDetails saveTokenExpiry:nil];
    [DNAccountController refreshAccessTokenSuccess:^(NSURLSessionDataTask *task, id responseData) {
        XCTAssertNotNil(responseData);
        waitingForBlock = NO;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTFail(@"Access token refresh failed");
        waitingForBlock = NO;
    }];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    
    while(waitingForBlock){
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }
}

- (void)testAccountRefreshAccessTokenWithSuspendedIntegration {
    
    __block BOOL waitingForBlock = YES;
    
    [DNDonkyNetworkDetails saveIsSuspended:YES];
    [DNDonkyNetworkDetails saveTokenExpiry:nil];
    [DNAccountController refreshAccessTokenSuccess:^(NSURLSessionDataTask *task, id responseData) {
        XCTAssertNotNil(responseData);
        waitingForBlock = NO;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTFail(@"Access token refresh failed %@", [error localizedDescription]);
        waitingForBlock = NO;
    }];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    
    while(waitingForBlock){
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }
}

- (void)testRefreshAccessTokenIntegration {
    __block BOOL waitingForBlock = YES;
    DNUserAuthentication *userAuthentication = [[DNUserAuthentication alloc] init];
    [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:NO route:kDNNetworkAuthentication httpMethod:DNPost parameters:[userAuthentication parameters] success:^(NSURLSessionDataTask *task, id responseData) {
        XCTAssertNotNil(responseData);
        waitingForBlock = NO;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTFail(@"Error: %@", [error localizedDescription]);
        waitingForBlock = NO;
    }];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    
    while(waitingForBlock){
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }
}

- (void)testUpdateUserDetailsIntegration {
    __block BOOL waitingForBlock = YES;
    
    NSString *userID = [NSString stringWithFormat:@"UnitTest_%d", arc4random()];
    DNUserDetails *currentUser = [[DNUserDetails alloc] initWithUserID:userID displayName:@"New" emailAddress:@"chris@me.com" mobileNumber:nil countryCode:nil lastName:@"Watson" firstName:@"Chris" avatarID:nil selectedTags:nil additionalProperties:nil];
    
    [DNAccountController updateUserDetails:currentUser success:^(NSURLSessionDataTask *task, id responseData) {
        XCTAssertTrue([[[[DNAccountController registrationDetails] userDetails] userID] isEqualToString:userID]);
        waitingForBlock = NO;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTFail(@"Error returned: %@", [error localizedDescription]);
        waitingForBlock = NO;
    }];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    
    while(waitingForBlock){
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }
}

- (void)testUpdateRegistrationDetailsIntegration {
    
     __block BOOL waitingForBlock = YES;
    
    NSString *userID = [NSString stringWithFormat:@"UnitTest_%d", arc4random()];
    DNUserDetails *userDetails = [[DNUserDetails alloc] initWithUserID:userID displayName:@"Unit Test" emailAddress:@"chris@me.com" mobileNumber:@"07545804334" countryCode:@"GBR" lastName:nil firstName:nil avatarID:nil selectedTags:nil additionalProperties:nil];
    DNDeviceDetails *deviceDetails = [[DNDeviceDetails alloc] initWithDeviceType:@"iPhone" name:@"my unit test" additionalProperties:nil];
    
    [DNAccountController updateRegistrationDetails:userDetails deviceDetails:deviceDetails success:^(NSURLSessionDataTask *task, id responseData) {
        XCTAssertTrue([[[[DNAccountController registrationDetails] userDetails] userID] isEqualToString:userID] &&
        [[[[DNAccountController registrationDetails] userDetails] displayName] isEqualToString:@"Unit Test"] &&
        [[[[DNAccountController registrationDetails] userDetails] emailAddress] isEqualToString:@"chris@me.com"] && [[[[DNAccountController registrationDetails] userDetails] countryCode] isEqualToString:@"GBR"] && [[[[DNAccountController registrationDetails] userDetails] mobileNumber] isEqualToString:@"07545804334"] && [[[[DNAccountController registrationDetails] deviceDetails] type] isEqualToString:@"iPhone"] && [[[[DNAccountController registrationDetails] deviceDetails] deviceName] isEqualToString:@"my unit test"]);
        waitingForBlock = NO;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTFail(@"Failed %@", [error localizedDescription]);
        waitingForBlock = NO;
    }];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    
    while(waitingForBlock){
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }
}

- (void)testUpdateDeviceDetailsIntegration {
    
    __block BOOL waitingForBlock = YES;
    
    DNDeviceDetails *device = [[DNDeviceDetails alloc] initWithDeviceType:@"Second iPhone ?" name:@"unit test" additionalProperties:nil];
    [DNAccountController updateDeviceDetails:device success:^(NSURLSessionDataTask *task, id responseData) {
        XCTAssertTrue([[[[DNAccountController registrationDetails] deviceDetails] type] isEqualToString:@"Second iPhone ?"] && [[[[DNAccountController registrationDetails] deviceDetails] deviceName] isEqualToString:@"unit test"]);
        waitingForBlock = NO;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTFail(@"Failed %@", [error localizedDescription]);
        waitingForBlock = NO;
    }];

    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    
    while(waitingForBlock){
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }
}

- (void)testReplaceRegistrationDetailsIntegration {

    __block BOOL waitingForBlock = YES;
    
    NSString *currentID = [[[DNAccountController registrationDetails] userDetails] userID];
    
    [DNAccountController replaceRegistrationDetailsWithUserDetails:nil deviceDetails:nil success:^(NSURLSessionDataTask *task, id responseData) {
        XCTAssertTrue(![currentID isEqualToString:[[[DNAccountController registrationDetails] userDetails] userID]]);
        waitingForBlock = NO;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTFail(@"Failed %@", [error localizedDescription]);
        waitingForBlock = NO;
    }];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    
    while(waitingForBlock){
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }
}

- (void)testReplaceRegistrationDetailsAnonymousIntegration {
    __block BOOL waitingForBlock = YES;
    
    NSString *userID = [NSString stringWithFormat:@"UnitTest_%d", arc4random()];
    DNUserDetails *userDetails = [[DNUserDetails alloc] initWithUserID:userID displayName:@"Display" emailAddress:nil mobileNumber:nil countryCode:nil lastName:nil firstName:nil avatarID:nil selectedTags:nil additionalProperties:nil];
    DNDeviceDetails *deviceDetails = [[DNDeviceDetails alloc] initWithDeviceType:@"iphonez?" name:@"ma iphonez" additionalProperties:nil];
    
    [DNAccountController replaceRegistrationDetailsWithUserDetails:userDetails deviceDetails:deviceDetails success:^(NSURLSessionDataTask *task, id responseData) {
        XCTAssertTrue([[[[DNAccountController registrationDetails] userDetails] userID] isEqualToString:userID] &&
                      [[[[DNAccountController registrationDetails] userDetails] displayName] isEqualToString:@"Display"] &&
                      [[[DNAccountController registrationDetails] userDetails] emailAddress] == nil && [[[DNAccountController registrationDetails] userDetails] countryCode] == nil && [[[DNAccountController registrationDetails] userDetails] mobileNumber] == nil && [[[[DNAccountController registrationDetails] deviceDetails] type] isEqualToString:@"iphonez?"] && [[[[DNAccountController registrationDetails] deviceDetails] deviceName] isEqualToString:@"ma iphonez"]);
        waitingForBlock = NO;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTFail(@"Failed %@", [error localizedDescription]);
        waitingForBlock = NO;
    }];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    
    while(waitingForBlock){
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }
}

- (void)testGetUserDetails {
    NSString *userID = [NSString stringWithFormat:@"UnitTest_%d", arc4random()];
    XCTAssertNotNil([DNAccountController userID:userID displayName:nil emailAddress:nil mobileNumber:nil countryCode:nil firstName:nil lastName:nil avatarID:nil selectedTags:nil additionalProperties:nil]);
}

- (void)testNonExistentServerNotificationIntegration {
    
    __block BOOL waitingForBlock = YES;
    
    [[DNNetworkController sharedInstance] serverNotificationForId:@"d5b076be-1882-432b-be93-631cfb77d11c" success:^(NSURLSessionDataTask *task, id responseData) {
        XCTAssertNil(responseData, @"Repsonse data");
        waitingForBlock = NO;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTAssertNotNil(error, @"Success, no notification found");
        waitingForBlock = NO;
    }];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    
    while(waitingForBlock){
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }
}

- (void)testContentNotificationsSaved {
    
    NSString *userID = [[[DNAccountController registrationDetails] userDetails] userID];
    DNContentNotification *contentNotification = [[DNContentNotification alloc] initWithUsers:@[userID] customType:@"UnitTest" data:@{@"kingMove" : @"A1 - B4"}];
    [[DNNetworkController sharedInstance] queueContentNotifications:@[contentNotification]];
    
    NSArray *allNotifs = [[DNDataController sharedInstance] contentNotificationsInTempContext:YES];
    
    __block BOOL found = NO;
    [allNotifs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DNContentNotification *notif = obj;
        if ([[notif content][@"customType"] isEqualToString:@"UnitTest"]) {
            found = YES;
            *stop = YES;
        }
    }];
    
    XCTAssertTrue(found);
}

- (void)testNotificationsSaved {
    
    DNServerNotification *notification = [[DNServerNotification alloc] initWithNotification:@{@"id" : @"123123123123123123121232"}];
    DNClientNotification *clientNotification = [[DNClientNotification alloc] initWithAcknowledgementNotification:notification];
    [clientNotification setNotificationType:@"Acknowledgement"];
    [[DNNetworkController sharedInstance] queueClientNotifications:@[clientNotification]];
    
    NSArray *allNotifs = [[DNDataController sharedInstance] clientNotificationsWithTempContext:YES];
    
    __block BOOL found = NO;
    [allNotifs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        DNClientNotification *notif = obj;
        if ([[notif notificationID] isEqualToString:@"123123123123123123121232"]) {
            found = YES;
            *stop = YES;
        }
    }];
    
    XCTAssertTrue(found);
}

- (void)testInitialiseInitialiseIntegration {
    
    __block BOOL waitingForBlock = YES;
    
    __block NSInteger done = 0;
    
    [[DNDonkyCore sharedInstance] initialiseWithAPIKey:@"vMBC8SHsILtV1g+UVnozZ0QmMKM4mcpNbNLfwUQnKq8P2z1XPMhhuHThwszJorUv32epCXMSjq3kwq0KM35w" userDetails:[[DNAccountController registrationDetails] userDetails] success:^(NSURLSessionDataTask *task, id responseData) {
        done ++;
        if (done == 4) {
            waitingForBlock = NO;
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTFail(@"Failed: %@", [error localizedDescription]);
    }];
    
    [[DNDonkyCore sharedInstance] initialiseWithAPIKey:@"vMBC8SHsILtV1g+UVnozZ0QmMKM4mcpNbNLfwUQnKq8P2z1XPMhhuHThwszJorUv32epCXMSjq3kwq0KM35w" userDetails:[[DNAccountController registrationDetails] userDetails] success:^(NSURLSessionDataTask *task, id responseData) {
        done ++;
        if (done == 4) {
            waitingForBlock = NO;
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTFail(@"Failed: %@", [error localizedDescription]);
    }];
    
    [[DNDonkyCore sharedInstance] initialiseWithAPIKey:@"vMBC8SHsILtV1g+UVnozZ0QmMKM4mcpNbNLfwUQnKq8P2z1XPMhhuHThwszJorUv32epCXMSjq3kwq0KM35w" userDetails:[[DNAccountController registrationDetails] userDetails] success:^(NSURLSessionDataTask *task, id responseData) {
        done ++;
        if (done == 4) {
            waitingForBlock = NO;
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTFail(@"Failed: %@", [error localizedDescription]);
    }];
    
    [[DNDonkyCore sharedInstance] initialiseWithAPIKey:@"vMBC8SHsILtV1g+UVnozZ0QmMKM4mcpNbNLfwUQnKq8P2z1XPMhhuHThwszJorUv32epCXMSjq3kwq0KM35w" userDetails:[[DNAccountController registrationDetails] userDetails] success:^(NSURLSessionDataTask *task, id responseData) {
        done ++;
        if (done == 4) {
            waitingForBlock = NO;
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTFail(@"Failed: %@", [error localizedDescription]);
    }];
    
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    
    while(waitingForBlock){
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }
}

- (void)testNilLogHandler {
    XCTAssertNoThrow([[DNDonkyCore sharedInstance] subscribeToLocalEvent:@"DonkyLogEvent" handler:nil]);
}



- (void)testLogEvent {
   
    DNLocalEventHandler handler = ^(DNLocalEvent *event) {
        XCTAssertTrue([[event data] rangeOfString:@"Log?"].location != NSNotFound);
    };
    
    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:@"UnitLog" handler:handler];

    DNErrorLog(@"Log?");

    [[DNDonkyCore sharedInstance] unSubscribeToLocalEvent:@"UnitLog" handler:handler];
}

- (void)testMultipleEventSubscribers {
    
    __block NSInteger count = 0;
    
    DNLocalEvent *event = [[DNLocalEvent alloc] initWithEventType:@"UnitTestEvent" publisher:nil timeStamp:nil data:nil];

    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:@"UnitTestEvent" handler:^(DNLocalEvent *event) {
        count ++;
        if (count == 2)
            XCTAssertNotNil(event);
    }];
    
    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:@"UnitTestEvent" handler:^(DNLocalEvent *event) {
        count ++;
        if (count == 2)
            XCTAssertNotNil(event);
    }];
    
    [[DNDonkyCore sharedInstance] publishEvent:event];

}

- (void)testLocalization {
    NSString *string = DNNetworkLocalizedString(@"dn_network_no_internet_tile");
    XCTAssertNotNil(string);
}

- (void)testNilLocalization {
    NSString *string = DNNetworkLocalizedString(@"dn_network_no_internet");
    XCTAssertTrue([string isEqualToString:@"dn_network_no_internet"]);
}

- (void)testRootViewController {
    XCTAssertNotNil([UIViewController applicationRootViewController]);
}

- (void)testArrayException {
    NSMutableDictionary *test = [[NSMutableArray alloc] init];
    XCTAssertThrows([test dnSetObject:@"test" forKey:@"test"]);
}

- (void)testDictionaryException {
    NSMutableDictionary *test = [[NSDictionary alloc] init];
    XCTAssertThrows([test dnSetObject:@"test" forKey:@"test"]);
}

- (void)testPushUpdate {
    XCTAssertNoThrow([DNNotificationController registerDeviceToken:[NSData data]]);
}

- (void)testDeletePush {
    XCTAssertNoThrow([DNNotificationController registerDeviceToken:nil]);
}

- (void)testEnablePush {
    [DNNotificationController enablePush:YES];
    XCTAssertTrue([DNDonkyNetworkDetails isPushEnabled]);
}

- (void)testDisablePush {
    [DNNotificationController enablePush:NO];
    XCTAssertFalse([DNDonkyNetworkDetails isPushEnabled]);
}

- (void)testReceivedNotification {
    XCTAssertNoThrow([DNNotificationController didReceiveNotification:@{} handleActionIdentifier:nil completionHandler:nil]);
}

- (void)testButtonSets {
    XCTAssertNotNil([DNConfigurationController buttonsAsSets]);
}

- (void)testConfiguration {
    XCTAssertNotNil([DNConfigurationController configuration]);
}

- (void)testStandardContacts {
    XCTAssertNotNil([DNConfigurationController standardContacts]);
}

- (void)testShowInternet {
    [DNNetworkHelper showNoConnectionAlert];
}

- (void)testCreateRetryObject {
    
    DNRequest *request = [[DNRequest alloc] initWithSecure:YES route:nil httpMethod:DNPut parameters:nil success:nil failure:nil];
    
    DNRetryObject *retry = [[DNRetryObject alloc] initWithRequest:request];
    
    XCTAssertNotNil(retry);
}

- (void)testIcrementRetryCount {
    DNRequest *request = [[DNRequest alloc] initWithSecure:YES route:nil httpMethod:DNPut parameters:nil success:nil failure:nil];
    
    DNRetryObject *retry = [[DNRetryObject alloc] initWithRequest:request];
    
    [retry incrementRetryCount];
    
    XCTAssertTrue([retry numberOfRetries] == 1);
}

- (void)testIncrementSectionCount {
    DNRequest *request = [[DNRequest alloc] initWithSecure:YES route:nil httpMethod:DNPut parameters:nil success:nil failure:nil];
    
    DNRetryObject *retry = [[DNRetryObject alloc] initWithRequest:request];
    
    [retry incrementSection];
    
    XCTAssertTrue([retry sectionRetries] == 1);
}

- (void)testAllServerNotificationsIntegration {
    __block BOOL waitingForBlock = YES;
    [[DNNetworkController sharedInstance] allServerNotificationsSuccess:^(NSURLSessionDataTask *task, id responseData) {
        waitingForBlock = NO;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTFail(@"Error: %@", [error localizedDescription]);
        waitingForBlock = NO;
    }];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    
    while(waitingForBlock){
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }
}

- (void)testErrorGeneration {
    
    NSError *error = [DNErrorController errorWithCode:DNCoreSDKErrorDuplicateSynchronise];
    NSError *error2 = [DNErrorController errorWithCode:DNCoreSDKErrorNoAPIKey];
    NSError *error3 = [DNErrorController errorWithCode:DNCoreSDKErrorNotAuthorised];
    NSError *error4 = [DNErrorController errorWithCode:DNCoreSDKErrorNotRegistered];
    NSError *error5 = [DNErrorController errorWithCode:DNCoreSDKFatalException];
    NSError *error6 = [DNErrorController errorWithCode:DNCoreSDKNetworkError];
    NSError *error7 = [DNErrorController errorWithCode:DNCoreSDKSuspendedUser];

    XCTAssertTrue([[error userInfo][NSLocalizedDescriptionKey] isEqualToString:@"A synchronise is already being performed. If there are pending content notifications when the current sync has finisehd, they will be sent..."]);
    
    XCTAssertTrue([[error2 userInfo][NSLocalizedDescriptionKey] isEqualToString:@"No API key found."]);
    
    XCTAssertTrue([[error3 userInfo][NSLocalizedDescriptionKey] isEqualToString:@"This deivce is not authroised. Therefore the request cannot be performed."]);
    
    XCTAssertTrue([[error4 userInfo][NSLocalizedDescriptionKey] isEqualToString:@"This deivce is not authroised. Therefore the request cannot be performed."]);
    
    XCTAssertTrue([[error5 userInfo][NSLocalizedDescriptionKey] isEqualToString:@"A fatal SDK exception has been caught and logged. Please try again..."]);

    XCTAssertTrue([[error6 userInfo][NSLocalizedDescriptionKey] isEqualToString:@"A network error has occurred."]);
    
    XCTAssertTrue([[error7 userInfo][NSLocalizedDescriptionKey] isEqualToString:@"User is suspended. Cannot perform secure network calls."]);
}

- (void)testMultipleDebugLog {
    
    __block BOOL waitingForBlock = YES;
    
        [DNLoggingController submitLogToDonkyNetwork:nil success:^(NSURLSessionDataTask *task, id responseData) {
        [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:^(NSURLSessionDataTask *task, NSError *error) {
            XCTAssertNotNil(error);
            waitingForBlock = NO;
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTFail(@"%@", [error localizedDescription]);
        waitingForBlock = NO;
    }];
 
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    
    while(waitingForBlock){
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }
}

@end
