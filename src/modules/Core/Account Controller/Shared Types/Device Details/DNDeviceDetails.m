//
//  DNDeviceDetails.m
//  Core Container
//
//  Created by Donky Networks on 16/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DNDeviceDetails.h"
#import "DNDeviceDetailsHelper.h"
#import "NSMutableDictionary+DNDictionary.h"
#import "DNKeychainHelper.h"
#import "DNDonkyNetworkDetails.h"
#import "DNPushNotificationUpdate.h"

static NSString *const DNRegistrationName = @"name";
static NSString *const DNRegistrationSecret = @"secret";
static NSString *const DNRegistrationModel = @"model";
static NSString *const DNRegistrationType = @"type";
static NSString *const DNRegistrationOperatingSystemVersion = @"operatingSystemVersion";
static NSString *const DNRegistrationOperatingSystem = @"operatingSystem";
static NSString *const DNRegistrationID = @"id";
static NSString *const DNRegistrationAdditionalProperties = @"additionalProperties";
static NSString *const DNRegistrationToken = @"token";

static NSString *const DNPushConfiguration = @"PushConfiguration";

@interface DNDeviceDetails ()

@property (nonatomic, strong) NSString *model;
@property (nonatomic, strong) NSString *deviceID;
@property (nonatomic, strong) NSString *osVersion;
@property (nonatomic, strong) NSString *operatingSystem;

@property (nonatomic, readwrite) NSString *type;
@property (nonatomic, readwrite) NSString *deviceName;
@property (nonatomic, readwrite) NSString *deviceSecret;
@property (nonatomic, readwrite) NSDictionary *additionalProperties;
@property (nonatomic, readwrite) NSString *apnsToken;
@property (nonatomic, readwrite) NSString *apnsAudio;

@end

@implementation DNDeviceDetails

- (instancetype) init {

    self = [super init];

    if (self) {

        [self setDeviceID:[DNDonkyNetworkDetails deviceID]];
        [self setModel:[DNDeviceDetailsHelper deviceModel]];
        [self setOperatingSystem:[DNDeviceDetailsHelper operatingSystem]];
        [self setOsVersion:[DNDeviceDetailsHelper osVersion]];

        [self setDeviceSecret:[DNDonkyNetworkDetails deviceSecret]];
        [self setDeviceName:[DNDeviceDetailsHelper deviceName]];

        [self setAdditionalProperties:[DNDeviceDetailsHelper additionalProperties]];
        [self setType:[DNDeviceDetailsHelper deviceType]];
        
        [self setApnsToken:[DNDonkyNetworkDetails deviceToken]];
        
        [self setApnsAudio:[DNDonkyNetworkDetails apnsAudio]];

    }

    return self;

}

- (instancetype)initWithDeviceType:(NSString *)type name:(NSString *) deviceName additionalProperties:(NSDictionary *) additionalProperties {

    self = [self init];
    
    if (self) {

        [self setType:type];
        [self setDeviceName:deviceName];
        [self setAdditionalProperties:additionalProperties];

    }

    return self;
}

- (NSMutableDictionary *)parameters {

    NSMutableDictionary *currentDevice = [[NSMutableDictionary alloc] init];

    [currentDevice dnSetObject:[self operatingSystem] forKey:DNRegistrationOperatingSystem];
    [currentDevice dnSetObject:[self osVersion] forKey:DNRegistrationOperatingSystemVersion];
    [currentDevice dnSetObject:[self type] forKey:DNRegistrationType];
    [currentDevice dnSetObject:[self model] forKey:DNRegistrationModel];
    [currentDevice dnSetObject:[self deviceName] forKey:DNRegistrationName];
    [currentDevice dnSetObject:[self additionalProperties] forKey:DNRegistrationAdditionalProperties];
    [currentDevice dnSetObject:[self deviceID] forKey:DNRegistrationID];
    [currentDevice dnSetObject:[self deviceSecret] forKey:DNRegistrationSecret];

    if ([self apnsToken]) {
        DNPushNotificationUpdate *update = [[DNPushNotificationUpdate alloc] initWithMessageAlertSound:[self apnsAudio] ? : @"Default"
                                                                                       deviceToken:[self apnsToken] ? : @""];
        [currentDevice dnSetObject:[update parameters] forKey:DNPushConfiguration];
    }

    return currentDevice;

}

@end