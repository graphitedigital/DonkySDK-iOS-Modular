//
//  DNAccountRegistrationResponse.m
//  NAAS Core SDK Container
//
//  Created by Donky Networks on 03/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DNAccountRegistrationResponse.h"
#import "NSDate+DNDateHelper.h"

@interface DNAccountRegistrationResponse ()
@property (nonatomic, readwrite) NSDate *tokenExpiry;
@property (nonatomic, readwrite) NSString *rootURL;
@property (nonatomic, readwrite) NSString *accessToken;
@property (nonatomic, readwrite) NSString *deviceId;
@property (nonatomic, readwrite) NSString *networkId;
@property (nonatomic, readwrite) NSString *userId;
@property (nonatomic, readwrite) NSString *networkProfileID;
@property (nonatomic, readwrite) NSDictionary *configuration;
@property (nonatomic, readwrite) NSString *signalRURL;
@end

//Constants
static NSString *DNNetworkProfileID = @"networkProfileId";
static NSString *kDKSecureServiceRoot = @"secureServiceRootUrl";
static NSString *kDKAccessDetails = @"accessDetails";
static NSString *kDKAccessToken = @"accessToken";
static NSString *kDKTokenExpiry = @"expiresOn";
static NSString *kDKDeviceID = @"deviceId";
static NSString *kDKNetworkID = @"networkId";
static NSString *kDKUserID = @"userId";
static NSString *DNConfiguration = @"configuration";
static NSString *DNSignalRUrl = @"signalRUrl";

@implementation DNAccountRegistrationResponse

- (instancetype)initWithRegistrationResponse:(NSDictionary *)responseData {

    self = [super init];

    if (self) {
        NSDictionary *accessDetails = responseData[kDKAccessDetails];
        
        [self setTokenExpiry:[NSDate donkyDateFromServer:accessDetails[kDKTokenExpiry]]];
        [self setRootURL:accessDetails[kDKSecureServiceRoot]];
        [self setAccessToken:accessDetails[kDKAccessToken]];
        [self setConfiguration:accessDetails[DNConfiguration]];

        [self setDeviceId:responseData[kDKDeviceID]];
        [self setNetworkId:responseData[kDKNetworkID]];
        [self setUserId:responseData[kDKUserID]];

        [self setNetworkProfileID:responseData[DNNetworkProfileID]];
        
        [self setSignalRURL:accessDetails[DNSignalRUrl]];

    }

    return self;
}

- (instancetype)initWithRefreshTokenResponse:(NSDictionary *)responseData {

    self = [super init];

    if (self) {
        [self setTokenExpiry:[NSDate donkyDateFromServer:responseData[kDKTokenExpiry]]];
        [self setAccessToken:responseData[kDKAccessToken]];
        [self setRootURL:responseData[kDKSecureServiceRoot]];
        [self setConfiguration:responseData[DNConfiguration]];
    }

    return self;
}


@end
