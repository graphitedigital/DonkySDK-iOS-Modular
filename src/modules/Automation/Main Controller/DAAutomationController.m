//
//  DAAutomationController.m
//  Automation
//
//  Created by Donky Networks on 04/04/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DAAutomationController.h"
#import <Donky_Core_SDK/DNNetworkController.h>
#import <Donky_Core_SDK/DNClientNotification.h>
#import <Donky_Core_SDK/NSMutableDictionary+DNDictionary.h>
#import <Donky_Core_SDK/NSDate+DNDateHelper.h>
#import <Donky_Core_SDK/DNDonkyCore.h>

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
    
//    double delayInSeconds = 3.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        [[DNNetworkController sharedInstance] synchronise];
//    });
}

@end
