//
//  DNDonkyNetworkDetails.m
//  Donky Network SDK Container
//
//  Created by Chris Watson on 06/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

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

@implementation DNDonkyNetworkDetails

+ (NSString *)deviceSecret {
    return [DNKeychainHelper objectForKey:kDNKeychainDeviceSecret] ? : [DNSystemHelpers generateGUID];
}

+ (NSString *)deviceID {
    return [DNUserDefaultsHelper objectForKey:DNDeviceID] ? : [DNSystemHelpers generateGUID];
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

+ (void)saveDeviceSecret:(NSString *) secret {
    [DNKeychainHelper saveObjectToKeychain:secret withKey:kDNKeychainDeviceSecret];
}

+ (void)saveDeviceID:(NSString *) deviceID {
    [DNUserDefaultsHelper saveObject:deviceID withKey:DNDeviceID];
}

+ (void)saveAccessToken:(NSString *)accessToken {
    [DNKeychainHelper saveObjectToKeychain:accessToken withKey:kDNKeychainAccessToken];
}

+ (void)saveSecureServiceRootUrl:(NSString *)secureServiceRootUrl {
    [DNUserDefaultsHelper saveObject:secureServiceRootUrl withKey:DNSecureServicesURL];
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

+ (BOOL)isDeviceRegistered {
    return [DNDonkyNetworkDetails networkId] != nil;
}

+ (BOOL)hasValidAccessToken {
    NSDate *reAuthenticationDate = [[DNDonkyNetworkDetails tokenExpiry] dateByAddingTimeInterval:-60.0];
    if (!reAuthenticationDate)
        return NO;
    
    return ![reAuthenticationDate donkyHasDateExpired];
}

+ (BOOL)newUserDetails {
    return [[[DNDataController sharedInstance] temporaryContext] hasChanges] || [[[DNDataController sharedInstance] mainContext] hasChanges];
}

+ (BOOL) isPushEnabled {
    return [[DNUserDefaultsHelper objectForKey:DNPushEnabled] boolValue];
}

+ (BOOL)isSuspended {
    return [[DNUserDefaultsHelper objectForKey:DNIsSuspended] boolValue];
}

@end
