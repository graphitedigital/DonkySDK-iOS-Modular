//
//  DNRegistrationDetails.m
//  Core Container
//
//  Created by Donky Networks on 17/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

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
        [self setDeviceDetails:deviceDetails];
        [self setClientDetails:clientDetails];
        [self setUserDetails:userDetails];
    }

    return self;
}

@end
