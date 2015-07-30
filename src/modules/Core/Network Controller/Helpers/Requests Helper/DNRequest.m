//
//  DNRequest.m
//  Donky Network SDK Container
//
//  Created by Chris Watson on 11/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNRequest.h"
#import "DNBlockDefinitions.h"

@interface DNRequest ()
@property(nonatomic, readwrite, getter=isSecure) BOOL secure;
@property(nonatomic, readwrite) NSString *route;
@property(nonatomic, readwrite) DonkyNetworkRoute method;
@property(nonatomic, readwrite) NSDictionary *parameters;
@property(nonatomic, readwrite) DNNetworkFailureBlock failureBlock;
@property(nonatomic, readwrite) DNNetworkSuccessBlock successBlock;
@end

@implementation DNRequest

- (instancetype)initWithSecure:(BOOL)secure route:(NSString *)route httpMethod:(DonkyNetworkRoute)method parameters:(NSDictionary *)parameters success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock {

    self = [super init];
    
    if (self) {

        [self setSecure:secure];
        [self setRoute:route];
        [self setMethod:method];
        [self setParameters:parameters];
        [self setSuccessBlock:successBlock];
        [self setFailureBlock:failureBlock];
        [self setNumberOfAttempts:0];

    }
    
    return self;
}

@end
