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
#import "DNDonkyNetworkDetails.h"

static NSString *const DNEventInteractivePushData = @"DonkyEventInteractivePushData";
static NSString *const DPPushNotificationID = @"notificationId";
static NSString *const DNInteractionResult = @"InteractionResult";
static NSString *const DNNotificationRichController = @"DRLogicMainController";

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
   [DNNotificationController registerDeviceToken:token remoteNotificationSound:nil];
}

+ (void)registerDeviceToken:(NSData *)token remoteNotificationSound:(NSString *)soundFileName {

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

    DNPushNotificationUpdate *update = [[DNPushNotificationUpdate alloc] initWithMessageAlertSound:soundFileName ? : [DNDonkyNetworkDetails apnsAudio] deviceToken:hexString ? [NSString stringWithString:hexString] : @""];

    [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:YES route:kDNNetworkRegistrationPush httpMethod:hexString ? DNPut : DNDelete parameters:[update parameters] success:^(NSURLSessionDataTask *task, id networkData) {
        DNInfoLog(@"Registering device token succeeded.");
        [DNDonkyNetworkDetails saveDeviceToken:hexString ? [NSString stringWithString:hexString] : @""];
        [DNDonkyNetworkDetails saveAPNSAudio:soundFileName];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DNErrorLog(@"Registering device token failed: %@", [error localizedDescription]);
        if ([token length]) {
            [DNNotificationController registerDeviceToken:token];
        }
    }];
}

+ (void)setRemoteNotificationSoundFile:(NSString *)soundFileName successBlock:(DNNetworkSuccessBlock)success failureBlock:(DNNetworkFailureBlock)failure {
    
    DNPushNotificationUpdate *notificationUpdate = [[DNPushNotificationUpdate alloc] initWithMessageAlertSound:soundFileName deviceToken:[DNDonkyNetworkDetails deviceToken]];
    
    [[DNNetworkController sharedInstance] performSecureDonkyNetworkCall:YES route:kDNNetworkRegistrationPush httpMethod:DNPut parameters:[notificationUpdate parameters] success:^(NSURLSessionDataTask *task, id networkData) {
        DNInfoLog(@"Sound file saved on the network.");
        [DNDonkyNetworkDetails saveAPNSAudio:soundFileName];
        
        if (success) {
            success(nil, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DNErrorLog(@"Sound file save failed: %@", [error localizedDescription]);
        if (failure) {
            failure(nil, nil);
        }
    }];
}

+ (void)enablePush:(BOOL)disable {
    [DNDonkyNetworkDetails savePushEnabled:disable];
    [DNNotificationController registerForPushNotifications];
}

+ (void)didReceiveNotification:(NSDictionary *)userInfo handleActionIdentifier:(NSString *)identifier completionHandler:(void (^)(NSString *))handler {
    if (![[DNDonkyCore sharedInstance] serviceForType:DNEventInteractivePushData]) {
        [[DNDonkyCore sharedInstance] subscribeToLocalEvent:DNEventInteractivePushData handler:^(DNLocalEvent *event) {
            if ([event isKindOfClass:[DNLocalEvent class]]) {
                if (handler) {
                    handler([event data]);
                }
            }
        }];
        [[DNDonkyCore sharedInstance] registerService:DNEventInteractivePushData instance:self];
    }

    if (identifier) {
        NSString *url = [userInfo[@"lbl1"] isEqualToString:identifier] ? userInfo[@"link1"] : userInfo[@"link2"];
        if (handler) {
            handler(url);
        }
    }

    NSString *notificationID = userInfo[DPPushNotificationID];
    //Publish background notification event:

    BOOL background = [[UIApplication sharedApplication] applicationState] != UIApplicationStateActive;

    [[DNNetworkController sharedInstance] serverNotificationForId:notificationID success:^(NSURLSessionDataTask *task, id responseData) {
        if (identifier) {
            DNLocalEvent *interactionResult = [[DNLocalEvent alloc] initWithEventType:DNInteractionResult
                                                                            publisher:NSStringFromClass([self class])
                                                                            timeStamp:[NSDate date]
                                                                                 data:[DNNotificationController reportButtonInteraction:identifier userInfo:responseData]];
            [[DNDonkyCore sharedInstance] publishEvent:interactionResult];
        }
        if (background) {
            DNLocalEvent *backgroundNotificationEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventBackgroundNotificationReceived
                                                                                      publisher:NSStringFromClass([self class])
                                                                                      timeStamp:[NSDate date]
                                                                                           data:@{@"NotificationID" : notificationID}];
            [[DNDonkyCore sharedInstance] publishEvent:backgroundNotificationEvent];
            [DNNotificationController loadNotificationMessage:responseData notificationID:nil];
        }

        if (handler) {
            handler(nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (handler) {
            handler(nil);
        }
    }];
}

+ (void)loadNotificationMessage:(DNServerNotification *)notification notificationID:(NSString *)notificationID {
    DNLocalEvent *loadedNotificationEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkyEventNotificationLoaded
                                                             publisher:NSStringFromClass([self class])
                                                             timeStamp:[NSDate date]
                                                                  data:notificationID ? : notification];
    [[DNDonkyCore sharedInstance] publishEvent:loadedNotificationEvent];
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

+ (void)resetApplicationBadgeCount {

    NSInteger count = 0;

    //Calculate unread count:
    if ([[DNDonkyCore sharedInstance] serviceForType:DNNotificationRichController]) {
        SEL unreadCount = NSSelectorFromString(@"unreadMessageCount");

        id serviceInstance = [[DNDonkyCore sharedInstance] serviceForType:DNNotificationRichController];

        if ([serviceInstance respondsToSelector:unreadCount]) {
            count += ((NSInteger (*)(id, SEL))[serviceInstance methodForSelector:unreadCount])(serviceInstance, unreadCount);
            DNInfoLog(@"Resetting to Master count: %ld", (long)count);
        }

        DNLocalEvent *changeBadgeEvent = [[DNLocalEvent alloc] initWithEventType:kDNDonkySetBadgeCount
                                                                       publisher:NSStringFromClass([DNNotificationController class])
                                                                       timeStamp:[NSDate date]
                                                                            data:@(count)];
        [[DNDonkyCore sharedInstance] publishEvent:changeBadgeEvent];
    }
}

@end
