//
//  DNServerNotification.m
//  NAAS Core SDK Container
//
//  Created by Donky Networks on 18/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DNServerNotification.h"
#import "NSMutableDictionary+DNDictionary.h"
#import "DNLoggingController.h"
#import "DNDonkyCore.h"
#import "NSDate+DNDateHelper.h"

@interface DNServerNotification ()
@property (nonatomic, readwrite) NSString *notificationType;
@property (nonatomic, readwrite) NSString *serverNotificationID;
@property (nonatomic, readwrite) NSDate *createdOn;
@property (nonatomic, readwrite) NSDictionary *data;
@end

static NSString *DNServerNotificationType = @"type";
static NSString *DNServerNotificationID = @"id";
static NSString *DNServerNotificationCreatedOn = @"createdOn";
static NSString *DNServerNotificationData = @"data";

@implementation DNServerNotification

- (instancetype)initWithNotification:(NSDictionary *) notification {

    self = [super init];

    if (self) {

        @try {
            [self setNotificationType:notification[DNServerNotificationType]];
            [self setServerNotificationID:notification[DNServerNotificationID]];
            [self setCreatedOn:[NSDate donkyDateFromServer:notification[DNServerNotificationCreatedOn]]];
            [self setData:[[notification[DNServerNotificationData] mutableCopy] donkyRemoveNullValues]];
        }
        @catch (NSException *e) {
            DNErrorLog(@"Fatal exception caught %@. Potential break in contract from server notification: %@", [e description], notification);
            [DNLoggingController submitLogToDonkyNetwork:nil success:nil failure:nil]; //Immediately submit to network

            [self setNotificationType:nil];
            [self setServerNotificationID:nil];
            [self setCreatedOn:nil];
            [self setData:nil];
        }
    }

    return self;
}

@end
