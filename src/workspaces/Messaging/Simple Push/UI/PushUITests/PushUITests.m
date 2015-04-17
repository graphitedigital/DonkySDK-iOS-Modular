//
//  PushUITests.m
//  PushUITests
//
//  Created by Chris Watson on 31/03/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DPUIBannerView.h"
#import "DPUINotificationController.h"
#import "DPUINotification.h"
#import "DNServerNotification.h"
#import "DNConstants.h"
#import "DNDonkyCore.h"
#import "DCMConstants.h"

@interface PushUITests : XCTestCase

@end

@implementation PushUITests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testbannerView {
    
    __block BOOL waitingForBlock = YES;
    
    [[DNDonkyCore sharedInstance] subscribeToLocalEvent:kDNDonkyEventSimplePushTapped handler:^(DNLocalEvent *event) {
        XCTAssertNil([event data]);
        waitingForBlock = NO;
    }];
    
    DNServerNotification *serverNotification = [[DNServerNotification alloc] initWithNotification:@{@{[NSDate date] : @"sentTimeStamp", [NSDate date] : @"msgSentTimeStamp", @"This is a test message" : @"body", @"richMessage" : @"messageType", @"123123123" : @"senderMessageId", @"123123123" : @"messageId", @{} : @"contextItems", @"123123123" : @"senderInternalUserId", @"123123" : @"avatarAssetId", @"Unit Test" : @"senderDisplayName"} : @"data"}];
    
    NSDictionary *data = @{kDNDonkyNotificationSimplePush : serverNotification};
    
    DNLocalEvent *localEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyNotificationSimplePush publisher:@"unit test" timeStamp:[NSDate date] data:data];
    
    [[DNDonkyCore sharedInstance] publishEvent:localEvent];
    
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    
    while(waitingForBlock){
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }
    
}

@end
