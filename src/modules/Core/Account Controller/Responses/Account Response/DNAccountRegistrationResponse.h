//
//  DNAccountRegistrationResponse.h
//  NAAS Core SDK Container
//
//  Created by Chris Watson on 03/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DNAccountRegistrationResponse : NSObject

@property (nonatomic, readonly) NSString *accessToken;

@property (nonatomic, readonly) NSString *rootURL;

@property (nonatomic, readonly) NSDate *tokenExpiry;

@property (nonatomic, readonly) NSString *deviceId;

@property (nonatomic, readonly) NSString *networkId;

@property (nonatomic, readonly) NSString *userId;

@property (nonatomic, readonly) NSString *networkProfileID;

@property(nonatomic, readonly) NSDictionary *configuration;

- (instancetype)initWithRegistrationResponse:(NSDictionary *)responseData;

- (instancetype)initWithRefreshTokenResponse:(NSDictionary *)responseData;

@end
