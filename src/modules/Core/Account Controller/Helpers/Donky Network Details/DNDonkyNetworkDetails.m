//
//  DNDonkyNetworkDetails.m
//  Donky Network SDK Container
//
//  Created by Donky Networks on 06/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "NSDate+DNDateHelper.h"
#import "DNKeychainHelper.h"
#import "DNConstants.h"
#import "DNAccountController.h"
#import "DNDonkyNetworkDetails.h"
#import "DNDeviceUser.h"
#import "DNUserDefaultsHelper.h"
#import "DNSystemHelpers.h"
#import "DNDeviceDetails.h"
#import "DNDataController.h"
#import "DNRegistrationDetails.h"
#import "DNUserDetails.h"

static NSString *const DNPushEnabled = @"PushEnabled";
static NSString *const DNDeviceID = @"DeviceID";
static NSString *const DNSecureServicesURL = @"SecureServicesURL";
static NSString *const DNTokenExpiry = @"TokenExpiry";
static NSString *const DNNetworkID = @"c3d2b4eb-3c8d-4b5b-b52c-cc92ada48f96";
static NSString *const DNApiKey = @"14f05d07-54c6-49ed-8c27-164e82fd1ec8";
static NSString *const DNIsSuspended = @"IsSuspended";
static NSString *const DNSDKVersion = @"SDKVersion";
static NSString *const DNOSVersion = @"OSVersion";
static NSString *const DNDeviceToken = @"DeviceToken";
static NSString *const DNAPNSAudio = @"APNSAudio";
static NSString *const DNNetworkProfileID = @"networkProfileID";
static NSString *const DNSignalRURL = @"DNSignalRURL";
static NSString *const DNMaximumNumberOfSavedChatMessages = @"MaximumNumberOfSavedChatMessages";
static NSString *const DNAPNSToken = @"APNSToken";

@implementation DNDonkyNetworkDetails

+ (void)saveDeviceSecret:(NSString *) secret {
    [DNKeychainHelper saveObjectToKeychain:secret withKey:kDNKeychainDeviceSecret];
}

+ (void)saveDeviceID:(NSString *) deviceID {
    [DNKeychainHelper saveObjectToKeychain:deviceID withKey:DNDeviceID];
}

+ (void)saveDeviceToken:(NSString *)deviceToken {
    [DNUserDefaultsHelper saveObject:deviceToken withKey:DNDeviceToken];
}

+ (void)saveAccessToken:(NSString *)accessToken {
    [DNKeychainHelper saveObjectToKeychain:accessToken withKey:kDNKeychainAccessToken];
}

+ (void)saveSecureServiceRootUrl:(NSString *)secureServiceRootUrl {
    [DNUserDefaultsHelper saveObject:secureServiceRootUrl withKey:DNSecureServicesURL];
}

+ (void)saveSignalRURL:(NSString *)signalRURL {
    [DNUserDefaultsHelper saveObject:signalRURL withKey:DNSignalRURL];
}

+ (void)saveTokenExpiry:(NSDate *)tokenExpiry {
    [DNUserDefaultsHelper saveObject:tokenExpiry withKey:DNTokenExpiry];
}

+ (void)saveNetworkID:(NSString *) networkId {
    [DNUserDefaultsHelper saveObject:networkId withKey:DNNetworkID];
}

+ (void)saveAPIKey:(NSString *)apiKey {
    [DNUserDefaultsHelper saveObject:apiKey withKey:DNApiKey];
}

+ (void)savePushEnabled:(BOOL)unRegister {
    [DNUserDefaultsHelper saveObject:@(unRegister) withKey:DNPushEnabled];
}

+ (void)saveIsSuspended:(BOOL)suspended {
    [DNUserDefaultsHelper saveObject:@(suspended) withKey:DNIsSuspended];
}

+ (void)saveSDKVersion:(NSString *)sdkVersion {
    [DNUserDefaultsHelper saveObject:sdkVersion withKey:DNSDKVersion];
}

+ (void)saveOperatingSystemVersion:(NSString *)operatingSystem {
    [DNUserDefaultsHelper saveObject:operatingSystem withKey:DNOSVersion];
}

+ (void)saveAPNSAudio:(NSString *)apnsAudio {
    [DNUserDefaultsHelper saveObject:apnsAudio withKey:DNAPNSAudio];
}

+ (void)saveNetworkProfileID:(NSString *)networkProfileID {
    [DNUserDefaultsHelper saveObject:networkProfileID withKey:DNNetworkProfileID];
}

+ (void)saveMaximumNumberOfSavedChatMessages:(NSInteger)maximumNumberOfSavedChatMessages {
    [DNUserDefaultsHelper saveObject:@(maximumNumberOfSavedChatMessages) withKey:DNMaximumNumberOfSavedChatMessages];
}

+ (NSString *)signalRURL {
    return [DNUserDefaultsHelper objectForKey:DNSignalRURL];
}

+ (BOOL)isDeviceRegistered {
    return [DNDonkyNetworkDetails networkId] != nil;
}

+ (BOOL)hasValidAccessToken {
    NSDate *reAuthenticationDate = [[DNDonkyNetworkDetails tokenExpiry] dateByAddingTimeInterval:-60.0];
    if (!reAuthenticationDate) {
        return NO;
    }
    
    return ![reAuthenticationDate donkyHasDateExpired];
}

+ (BOOL)newUserDetails {
    return [[[DNDataController sharedInstance] mainContext] hasChanges];
}

+ (BOOL)isPushEnabled {
    return [[DNUserDefaultsHelper objectForKey:DNPushEnabled] boolValue];
}

+ (BOOL)isSuspended {
    return [[DNUserDefaultsHelper objectForKey:DNIsSuspended] boolValue];
}

+ (NSString *)deviceSecret {
    return [DNKeychainHelper objectForKey:kDNKeychainDeviceSecret] ? : [DNSystemHelpers generateGUID];
}

+ (NSString *)deviceID {
    
    //Check old store:
    if ([DNUserDefaultsHelper objectForKey:DNDeviceID]) {
        //Get old deviceID:
        NSString *oldDeviceId = [DNUserDefaultsHelper objectForKey:DNDeviceID];
        //Save to keychain:
        [DNDonkyNetworkDetails saveDeviceID:oldDeviceId];
        //Remove old data:
        [DNUserDefaultsHelper deleteObjectForKey:DNDeviceID];
    }
    
    return [DNKeychainHelper objectForKey:DNDeviceID] ? : [DNSystemHelpers generateGUID];
}

+ (NSString *)accessToken {
    return [DNKeychainHelper objectForKey:kDNKeychainAccessToken];
}

+ (NSString *)secureServiceRootUrl {
    return [DNUserDefaultsHelper objectForKey:DNSecureServicesURL];
}

+ (NSDate *)tokenExpiry {
    return [DNUserDefaultsHelper objectForKey:DNTokenExpiry];
}

+ (NSString *)networkId {
    return [DNUserDefaultsHelper objectForKey:DNNetworkID];
}

+ (NSString *)apiKey {
    return [DNUserDefaultsHelper objectForKey:DNApiKey];
}

+ (NSString *)savedSDKVersion {
    return [DNUserDefaultsHelper objectForKey:DNSDKVersion];
}

+ (NSString *)savedOperatingSystemVersion {
    return [DNUserDefaultsHelper objectForKey:DNOSVersion];
}

+ (NSString *)deviceToken {
    return [DNUserDefaultsHelper objectForKey:DNDeviceToken];
}

+ (NSString *)apnsAudio {
    return [DNUserDefaultsHelper objectForKey:DNAPNSAudio];
}

+ (NSString *)networkProfileID {
    return [DNUserDefaultsHelper objectForKey:DNNetworkProfileID];
}

+ (NSInteger)maximumNumberOfSavedChatMessages {
    return [[DNUserDefaultsHelper objectForKey:DNMaximumNumberOfSavedChatMessages] integerValue] ? : kDonkyMaxNumberOfSavedChatMessages;
}

@end
