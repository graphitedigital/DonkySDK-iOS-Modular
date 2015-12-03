//
//  DAAutomationController.m
//  Automation
//
//  Created by Chris Watson on 04/04/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import "DAAutomationController.h"
#import "DNNetworkController.h"
#import "DNClientNotification.h"
#import "NSMutableDictionary+DNDictionary.h"
#import "NSDate+DNDateHelper.h"
#import "DNDonkyCore.h"

@implementation DAAutomationController

+ (void)executeThirdPartyTriggerWithKey:(NSString *)key customData:(NSDictionary *)customData {
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];

    [data dnSetObject:customData forKey:@"customData"];
    [data dnSetObject:key forKey:@"triggerKey"];
    [data dnSetObject:@[] forKey:@"triggerActionsExecuted"];
    [data dnSetObject:[[NSDate date] donkyDateForServer] forKey:@"timestamp"];

    DNClientNotification *clientNotification = [[DNClientNotification alloc] initWithType:@"ExecuteThirdPartyTriggers" data:data acknowledgementData:nil];
    [[DNNetworkController sharedInstance] queueClientNotifications:@[clientNotification]];
}

+ (void)executeThirdPartyTriggerWithKeyImmediately:(NSString *)key customData:(NSDictionary *)customData {
    //Create the trigger call:
    [DAAutomationController executeThirdPartyTriggerWithKey:key customData:customData];
    [[DNNetworkController sharedInstance] synchronise];
}

@end
