//
//  DNPushNotificationUpdate.m
//  Donky Network SDK Container
//
//  Created by Chris Watson on 06/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNPushNotificationUpdate.h"
#import "NSMutableDictionary+DNDictionary.h"

@interface DNPushNotificationUpdate ()
@property(nonatomic, readwrite) NSString *token;
@end

static NSString *DNRegistrationType = @"Type";
static NSString *DNToken = @"token";
static NSString *DNBundleID = @"bundleId";
static NSString *DNMessageAlertSound = @"messageAlertSound";
static NSString *DNContactAlertSound = @"contactAlertSound";

@implementation DNPushNotificationUpdate

- (instancetype)initWithPushToken:(NSString *)token {
    
    self = [super init];
    
    if (self) {

        [self setToken:token];

    }
    
    return self;
}

- (NSDictionary *) parameters {

    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];

    [parameters dnSetObject:[self token] forKey:DNToken];
    [parameters dnSetObject:@"apns" forKey:DNRegistrationType];
    [parameters dnSetObject:[[NSBundle mainBundle] bundleIdentifier] forKey:DNBundleID];

    return parameters;
}

@end
