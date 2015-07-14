//
//  DNNotificationController.m
//  NAAS Core SDK Container
//
//  Created by Chris Watson on 16/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNAccountController.h"
#import "DNNotificationController.h"
#import "DNLoggingController.h"
#import "DNNetworkController.h"
#import "DNConstants.h"
#import "DNSystemHelpers.h"
#import "DNPushNotificationUpdate.h"
#import "DNDonkyCore.h"
#import "DNDonkyNetworkDetails.h"
#import "DNConfigurationController.h"
#import "NSDate+DNDateHelper.h"
#import "NSMutableDictionary+DNDictionary.h"
#import "DNErrorController.h"

static NSString *const DNEventInteractivePushData = @"DonkyEventInteractivePushData";
static NSString *const DPPushNotificationID = @"notificationId";

static NSString *const DNInteractionResult = @"InteractionResult";

@implementation DNNotificationController

+ (void)registerForPushNotifications {
    
    //Register Module:
    DNModuleDefinition *notificationModule = [[DNModuleDefinition alloc] initWithName:NSStringFromClass([self class]) version:kDNDonkyNotificationVersion];
    [[DNDonkyCore sharedInstance] registerModule:notificationModule];
    
#if TARGET_IPHONE_SIMULATOR
    DNErrorLog(@"Cannot register for push notifications on simulator");
    return;
#else

    if ([DNSystemHelpers systemVersionAtLeast:8.0]) {
        NSMutableSet *buttonSets = [DNConfigurationController buttonsAsSets];
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings
                settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                      categories:buttonSets]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }

    else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge];
    }

#endif
    
}

+ (void)registerDeviceToken:(NSData *)token {
    NSMutableString *hexString = nil;
    if (token && [DNDonkyNetworkDetails isPushEnabled]) {
        const unsigned char *dataBuffer = (const unsigned char *) [token bytes];

        NSUInteger dataLength = [token length];
        hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];

        for (int i = 0; i < dataLength; ++i) {
            [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long) dataBuffer[i]]];
        }

        DNInfoLog(@"Uploading device Token: %@...", [NSString stringWithString:hexString]);
    }

    DNPushNotificationUpdate *update = [[DNPushNotificationUpdate alloc] initWithPushToken:hexString ? [NSString stringWithString:hexString] : @""];

    [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:YES route:kDNNetworkRegistrationPush httpMethod:hexString ? DNPut : DNDelete parameters:[update parameters] success:^(NSURLSessionDataTask *task, id networkData) {
        DNInfoLog(@"Registering device token succeeded.");
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DNErrorLog(@"Registering device token failed: %@", [error localizedDescription]);
    }];
}

+ (void)enablePush:(BOOL)disable {
    [DNDonkyNetworkDetails savePushEnabled:disable];
    [DNNotificationController registerForPushNotifications];
}

+ (void)didReceiveNotification:(NSDictionary *)userInfo handleActionIdentifier:(NSString *)identifier completionHandler:(void (^)(NSString *))handler {

    if (![[DNDonkyCore sharedInstance] serviceForType:DNEventInteractivePushData]) {
        [[DNDonkyCore sharedInstance] subscribeToLocalEvent:DNEventInteractivePushData handler:^(DNLocalEvent *event) {
            if ([event isKindOfClass:[DNLocalEvent class]])
                handler([event data]);
        }];
        [[DNDonkyCore sharedInstance] registerService:DNEventInteractivePushData instance:self];
    }

    if (identifier) {
        NSString *url = [userInfo[@"lbl1"] isEqualToString:identifier] ? userInfo[@"link1"] : userInfo[@"link2"];
        handler(url);
    }

    NSString *notificationID = userInfo[DPPushNotificationID];
    //Publish background notification event:
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        DNLocalEvent *backgroundNotificationEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventBackgroundNotificationReceived
                                                                                  publisher:NSStringFromClass([self class])
                                                                                  timeStamp:[NSDate date]
                                                                                       data:@{@"NotificationID" : notificationID}];
        [[DNDonkyCore sharedInstance] publishEvent:backgroundNotificationEvent];

        [[DNNetworkController sharedInstance] serverNotificationForId:notificationID success:^(NSURLSessionDataTask *task, id responseData) {
            NSLog(@"%@", responseData);
            if (identifier) {
                DNLocalEvent *interactionResult = [[DNLocalEvent alloc] initWithEventType:DNInteractionResult publisher:NSStringFromClass([self class]) timeStamp:[NSDate date] data:[DNNotificationController reportButtonInteraction:identifier userInfo:responseData]];
                [[DNDonkyCore sharedInstance] publishEvent:interactionResult];
            }
            handler(nil);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if ([DNErrorController serviceReturned:404 error:error]) {
                //This notification has already been ack'd, we can then send out a local event With the ID
                DNLocalEvent *ackedEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventNotificationLoaded
                                                                         publisher:NSStringFromClass([self class])
                                                                         timeStamp:[NSDate date]
                                                                              data:notificationID];
                [[DNDonkyCore sharedInstance] publishEvent:ackedEvent];
            }
            handler(nil);
        }];
    }
    else {
        [[DNNetworkController sharedInstance] synchroniseSuccess:^(NSURLSessionDataTask *task, id responseData) {
            handler(nil);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            handler(nil);
        }];
    }
}

+ (NSMutableDictionary *)reportButtonInteraction:(NSString *)identifier userInfo:(DNServerNotification *)notification {

    NSDate *interactionDate = [NSDate date];

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];

    [params dnSetObject:@"iOS" forKey:@"operatingSystem"];
    [params dnSetObject:[interactionDate donkyDateForServer] forKey:@"interactionTimeStamp"];

    //First button set index:
    NSArray *buttonSetAction = [[notification data][@"buttonSets"] firstObject][@"buttonSetActions"];

    [params dnSetObject:[[buttonSetAction firstObject][@"label"] isEqualToString:identifier] ? @"Button1" : @"Button2" forKey:@"userAction"];

    [params dnSetObject:[[notification data][@"buttonSets"] firstObject][@"interactionType"] forKey:@"interactionType"];

    [params dnSetObject:[NSString stringWithFormat:@"%@|%@", [buttonSetAction firstObject][@"label"] ? : @"", [buttonSetAction lastObject][@"label"] ? : @""] forKey:@"buttonDescription"];

    //Set request ids:
    [params dnSetObject:[notification data][@"senderInternalUserId"] forKey:@"senderInternalUserId"];
    [params dnSetObject:[notification data][@"senderMessageId"] forKey:@"senderMessageId"];
    [params dnSetObject:[notification data][@"messageId"] forKey:@"messageId"];

    [params dnSetObject:[[notification createdOn] donkyDateForServer] forKey:@"messageSentTimeStamp"];
    
    double timeToInteract = [interactionDate timeIntervalSinceDate:[notification createdOn]];
    
    if (isnan(timeToInteract))
        timeToInteract = 0;
    
    [params dnSetObject:@(timeToInteract) forKey:@"timeToInteractionSeconds"];
    [params dnSetObject:[buttonSetAction count] == 2 ? @"twoButton" : @"oneButton" forKey:@"interactionType"];

    [params dnSetObject:[notification data][@"contextItems"] forKey:@"contextItems"];

    return params;
}

@end
