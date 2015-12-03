//
//  DNDonkyNetworkDetails.h
//  Donky Network SDK Container
//
//  Created by Donky Networks on 06/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNDeviceDetails.h"

@interface DNDonkyNetworkDetails : NSObject

+ (void)saveDeviceSecret:(NSString *)secret;

+ (void)saveDeviceID:(NSString *)deviceID;

+ (void)saveDeviceToken:(NSString *)deviceToken;

+ (void)saveAccessToken:(NSString *)accessToken;

+ (void)saveSecureServiceRootUrl:(NSString *)secureServiceRootUrl;

+ (void)saveSignalRURL:(NSString *)signalRURL;

+ (void)saveTokenExpiry:(NSDate *)tokenExpiry;

+ (void)saveNetworkID:(NSString *)networkId;

+ (void)saveAPIKey:(NSString *)apiKey;

+ (void)savePushEnabled:(BOOL)unRegister;

+ (void)saveIsSuspended:(BOOL)suspended;

+ (void)saveSDKVersion:(NSString *)sdkVersion;

+ (void)saveOperatingSystemVersion:(NSString *)operatingSystem;

+ (void)saveAPNSAudio:(NSString *)apnsAudio;

+ (void)saveNetworkProfileID:(NSString *)networkProfileID;

+ (void)saveMaximumNumberOfSavedChatMessages:(NSInteger)maximumNumberOfSavedChatMessages;

+ (NSString *)deviceSecret;

+ (NSString *)deviceID;

+ (NSString *)accessToken;

+ (NSString *)secureServiceRootUrl;

+ (NSDate *)tokenExpiry;

+ (NSString *)networkId;

+ (NSString *)apiKey;

+ (NSString *)savedSDKVersion;

+ (NSString *)savedOperatingSystemVersion;

+ (NSString *)deviceToken;

+ (NSString *)apnsAudio;

+ (NSString *)networkProfileID;

+ (NSInteger)maximumNumberOfSavedChatMessages;

+ (NSString *)signalRURL;

+ (BOOL)isDeviceRegistered;

+ (BOOL)hasValidAccessToken;

+ (BOOL)newUserDetails;

+ (BOOL)isPushEnabled;

+ (BOOL)isSuspended;

@end
