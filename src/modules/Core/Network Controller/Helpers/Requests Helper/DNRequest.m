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
        
        self.secure = secure;
        self.route = route;
        self.method = method;
        self.parameters = parameters;
        self.successBlock = successBlock;
        self.failureBlock = failureBlock;
        self.numberOfAttempts = 0;
    }
    
    return self;
}

@end
