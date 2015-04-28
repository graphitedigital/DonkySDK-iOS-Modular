//
//  DNRegistrationDetails.m
//  Core Container
//
//  Created by Chris Watson on 17/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNRegistrationDetails.h"
#import "DNDeviceDetails.h"
#import "DNClientDetails.h"
#import "DNUserDetails.h"

@interface DNRegistrationDetails ()
@property(nonatomic, readwrite) DNDeviceDetails *deviceDetails;
@property(nonatomic, readwrite) DNClientDetails *clientDetails;
@property(nonatomic, readwrite) DNUserDetails *userDetails;
@end

@implementation DNRegistrationDetails
- (instancetype)initWithDeviceDetails:(DNDeviceDetails *)deviceDetails clientDetails:(DNClientDetails *)clientDetails userDetails:(DNUserDetails *)userDetails {

    self = [super init];

    if (self) {
        self.deviceDetails = deviceDetails;
        self.clientDetails = clientDetails;
        self.userDetails = userDetails;
    }

    return self;
}

@end
