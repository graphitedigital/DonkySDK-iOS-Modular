//
//  DRIMainControllerHelper.m
//  RichInbox
//
//  Created by Donky Networks on 23/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DRIMainControllerHelper.h"
#import "DNSystemHelpers.h"
#import "UIViewController+DNRootViewController.h"
#import "DNConstants.h"
#import "DRConstants.h"
#import "DNDonkyCore.h"
#import "NSDate+DNDateHelper.h"
#import "DNDataController.h"
#import "DNLoggingController.h"
#import "DNQueueManager.h"

static NSString *const DRIExpiryTimeStamp = @"expiryTimeStamp";
static NSString *const DRIType = @"type";
static NSString *const DRIMessageID = @"messageID";

@implementation DRIMainControllerHelper

+ (DNLocalEventHandler)richMessageBadgeCount {

    DNLocalEventHandler richMessageBadgeCount = ^(DNLocalEvent *event) {

        NSInteger count = [[UIApplication sharedApplication] applicationIconBadgeNumber];
        count -= [[event data] integerValue];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            DNLocalEvent *changeBadgeEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkySetBadgeCount
                                                                           publisher:NSStringFromClass([DRIMainControllerHelper class])
                                                                           timeStamp:[NSDate date]
                                                                                data:@(count)];
            [[DNDonkyCore sharedInstance] publishEvent:changeBadgeEvent];
        });

    };

    return richMessageBadgeCount;
}

@end
