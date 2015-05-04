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

static NSString *const DPPushNotificationID = @"notificationId";

@implementation DNNotificationController

+ (void)registerForPushNotifications {

#if TARGET_IPHONE_SIMULATOR
    DNErrorLog(@"Cannot register for push notifications on simulator");
    return;
#else

    if ([DNSystemHelpers donkySystemVersionAtLeast:8.0]) {
        NSMutableSet *buttonSets = [DNConfigurationController buttonsAsSets];
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings
                settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                      categories:buttonSets]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }

    else
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge];

#endif

}

+ (void)registerDeviceToken:(NSData *)token {

    NSMutableString *hexString = nil;

    if (token && [DNDonkyNetworkDetails isPushEnabled]) {
        const unsigned char *dataBuffer = (const unsigned char *) [token bytes];

        NSUInteger dataLength = [token length];
        hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];

        for (int i = 0; i < dataLength; ++i)
            [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long) dataBuffer[i]]];

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

    if (![[DNDonkyCore sharedInstance] serviceForType:@"DonkyEventInteractivePushData"]) {
        [[DNDonkyCore sharedInstance] subscribeToLocalEvent:@"DonkyEventInteractivePushData" handler:^(DNLocalEvent *event) {
            if ([event isKindOfClass:[DNLocalEvent class]])
                handler([event data]);
        }];
        [[DNDonkyCore sharedInstance] registerService:@"DonkyEventInteractivePushData" instance:self];
    }


    if (identifier) {
        NSString *url = [userInfo[@"lbl1"] isEqualToString:identifier] ? userInfo[@"link1"] : userInfo[@"link2"];
        handler(url);
    }

    NSString *notificationID = userInfo[DPPushNotificationID];
    [[DNNetworkController sharedInstance] serverNotificationForId:notificationID success:^(NSURLSessionDataTask *task, id responseData) {
        NSLog(@"%@", responseData);
        if (identifier) {
            DNLocalEvent *interactionResult = [[DNLocalEvent alloc] initWithEventType:@"InteractionResult" publisher:NSStringFromClass([self class]) timeStamp:[NSDate date] data:[DNNotificationController reportButtonInteraction:identifier userInfo:responseData]];
            [[DNDonkyCore sharedInstance] publishEvent:interactionResult];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {

    }];
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

    [params dnSetObject:[[notification createdOn] donkyDateForServer] forKey:@"msgSentTimeStamp"];
    [params dnSetObject:@([interactionDate timeIntervalSinceDate:[notification createdOn]]) forKey:@"timeToInteractionSeconds"];
    [params dnSetObject:[buttonSetAction count] == 2 ? @"twoButton" : @"oneButton" forKey:@"interactionType"];

    [params dnSetObject:[notification data][@"contextItems"] forKey:@"contextItems"];

    return params;
}

@end
