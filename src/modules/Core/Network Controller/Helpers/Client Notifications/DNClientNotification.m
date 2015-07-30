//
//  DNClientNotification.m
//  Core Container
//
//  Created by Chris Watson on 19/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNClientNotification.h"
#import "DNServerNotification.h"
#import "DNNotification.h"
#import "NSMutableDictionary+DNDictionary.h"
#import "NSDate+DNDateHelper.h"
#import "DNSystemHelpers.h"

static NSString *const DNServerNotificationID = @"serverNotificationId";
static NSString *const DNSentTime = @"sentTime";
static NSString *const DNType = @"type";
static NSString *const DNCustomNotificationType = @"customNotificationType";
static NSString *const DNCustomType = @"customType";
static NSString *const DNCustom = @"Custom";

@interface DNClientNotification ()
@property(nonatomic, readwrite) NSString *notificationID;
@property(nonatomic, readwrite) NSDate *sentTime;
@end

@implementation DNClientNotification

- (instancetype)initWithAcknowledgementNotification:(DNServerNotification *)notification {

    self = [super init];
    
    if (self) {

        [self setNotificationID:[notification serverNotificationID]];
        [self setSentTime:[notification createdOn]];
        [self setSendTries:@(0)];

        [self setAcknowledgementDetails:[self acknowledgementDetailsFromNotification:notification]];

    }

    return self;
}

- (instancetype)initWithType:(NSString *)type data:(NSDictionary *)data acknowledgementData:(DNServerNotification *)notification {

    self = [super init];

    if (self) {

        [self setNotificationID:[notification serverNotificationID] ? : [DNSystemHelpers generateGUID]];
        [self setNotificationType:type];
        [self setData:data];
        [self setSendTries:@(0)];

        [self setAcknowledgementDetails:[self acknowledgementDetailsFromNotification:notification]];
    }

    return self;
}

- (instancetype)initWithNotification:(DNNotification *)notification {

    self = [super init];
    
    if (self) {
        [self setNotificationID:[notification serverNotificationID] ? : [notification notificationID] ? : [DNSystemHelpers generateGUID]];
        [self setSendTries:[notification sendTries]];
        [self setSentTime:[notification data][DNSentTime]];
        [self setNotificationType:[notification type]];
        [self setAcknowledgementDetails:[notification acknowledgementDetails]];
        [self setData:[notification data]];
    }

    return self;
}

- (NSMutableDictionary *)acknowledgementDetailsFromNotification:(DNServerNotification *) notification {
    
    NSMutableDictionary *acknowledgement = [[NSMutableDictionary alloc] init];
    [acknowledgement dnSetObject:[notification serverNotificationID] forKey:DNServerNotificationID];
    [acknowledgement dnSetObject:[[notification createdOn] donkyDateForServer] forKey:DNSentTime];
    [acknowledgement dnSetObject:[notification notificationType] forKey:DNType];
    
    if ([[notification notificationType] isEqualToString:DNCustom]) {
        [acknowledgement dnSetObject:[notification data][DNCustomType] forKey:DNCustomNotificationType];
    }
    
    return acknowledgement;
}



@end
