//
//  DNDonkyNetworkDetails.h
//  Donky Network SDK Container
//
//  Created by Chris Watson on 06/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNDeviceDetails.h"

@interface DNDonkyNetworkDetails : NSObject

+ (NSString *)deviceSecret;

+ (NSString *)deviceID;

+ (NSString *)accessToken;

+ (NSString *)secureServiceRootUrl;

+ (NSDate *)tokenExpiry;

+ (NSString *)networkId;

+ (NSString *)apiKey;

+ (void)saveDeviceSecret:(NSString *)secret;

+ (void)saveDeviceID:(NSString *)deviceID;

+ (void)saveAccessToken:(NSString *)accessToken;

+ (void)saveSecureServiceRootUrl:(NSString *)secureServiceRootUrl;

+ (void)saveTokenExpiry:(NSDate *)tokenExpiry;

+ (void)saveNetworkID:(NSString *)networkId;

+ (void)saveAPIKey:(NSString *)apiKey;

+ (void)savePushEnabled:(BOOL)unRegister;

+ (void)saveIsSuspended:(BOOL)suspended;

+ (BOOL)isDeviceRegistered;

+ (BOOL)hasValidAccessToken;

+ (BOOL)newUserDetails;

+ (BOOL)isPushEnabled;

+ (BOOL)isSuspended;

@end
