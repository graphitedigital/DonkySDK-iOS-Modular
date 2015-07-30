//
//  DNDeviceDetails.m
//  Core Container
//
//  Created by Chris Watson on 16/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNDeviceDetails.h"
#import "DNDeviceDetailsHelper.h"
#import "NSMutableDictionary+DNDictionary.h"
#import "DNKeychainHelper.h"
#import "DNDonkyNetworkDetails.h"

static NSString *const DNRegistrationName = @"name";
static NSString *const DNRegistrationSecret = @"secret";
static NSString *const DNRegistrationModel = @"model";
static NSString *const DNRegistrationType = @"type";
static NSString *const DNRegistrationOperatingSystemVersion = @"operatingSystemVersion";
static NSString *const DNRegistrationOperatingSystem = @"operatingSystem";
static NSString *const DNRegistrationId = @"id";
static NSString *const DNRegistrationAdditionalProperties = @"additionalProperties";

@interface DNDeviceDetails ()

@property(nonatomic, readwrite) NSString *type;
@property(nonatomic, strong) NSString *model;
@property(nonatomic, strong) NSString *operatingSystem;
@property(nonatomic, strong) NSString *osVersion;
@property(nonatomic, readwrite) NSString *deviceName;
@property(nonatomic, readwrite) NSDictionary *additionalProperties;

@property(nonatomic, strong) NSString *deviceID;
@property(nonatomic, readwrite) NSString *deviceSecret;

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

    }

    return self;

}

- (instancetype) initWithDeviceType:(NSString *) type name:(NSString *) deviceName additionalProperties:(NSDictionary *) additionalProperties {
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
    [currentDevice dnSetObject:[self deviceID] forKey:DNRegistrationId];
    [currentDevice dnSetObject:[self deviceSecret] forKey:DNRegistrationSecret];

    return currentDevice;
}

@end
