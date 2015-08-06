//
//  DNAccountRegistrationResponse.m
//  NAAS Core SDK Container
//
//  Created by Chris Watson on 03/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNAccountRegistrationResponse.h"
#import "NSDate+DNDateHelper.h"

static NSString *const DNNetworkProfileID = @"networkProfileId";

@interface DNAccountRegistrationResponse ()
@property (nonatomic, readwrite) NSDate *tokenExpiry;
@property (nonatomic, readwrite) NSString *rootURL;
@property (nonatomic, readwrite) NSString *accessToken;
@property (nonatomic, readwrite) NSString *deviceId;
@property (nonatomic, readwrite) NSString *networkId;
@property (nonatomic, readwrite) NSString *userId;
@property (nonatomic, readwrite) NSString *networkProfileID;
@property(nonatomic, readwrite) NSDictionary *configuration;
@end

//Constants
static NSString *kDKAccessDetails = @"accessDetails";
static NSString *kDKSecureServiceRoot = @"secureServiceRootUrl";
static NSString *kDKAccessToken = @"accessToken";
static NSString *kDKTokenExpiry = @"expiresOn";
static NSString *kDKDeviceID = @"deviceId";
static NSString *kDKNetworkID = @"networkId";
static NSString *kDKUserID = @"userId";
static NSString *DNConfiguration = @"configuration";

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

    }

    return self;
}

- (instancetype)initWithRefreshTokenResponse:(NSDictionary *)responseData {

    self = [super init];

    if (self) {
        [self setTokenExpiry:[NSDate donkyDateFromServer:responseData[kDKTokenExpiry]]];
        [self setAccessToken:responseData[kDKAccessToken]];
        [self setRootURL:responseData[kDKSecureServiceRoot]];
    }

    return self;
}


@end
