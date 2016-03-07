//
//  DNAuthResponse.m
//  DonkyMaster
//
//  Created by Chris Watson on 18/02/2016.
//  Copyright © 2016 Donky Networks. All rights reserved.
//

#import "DNAuthResponse.h"
#import "NSMutableDictionary+DNDictionary.h"

@interface DNAuthResponse ()
@property(nonatomic, readwrite) NSString *nonce;
@property(nonatomic, readwrite) NSString *provider;
@property(nonatomic, getter=isNonceRequired) BOOL nonceRequired;
@property(nonatomic, readwrite) NSString *authenticationID;
@end

@implementation DNAuthResponse


- (instancetype)initWithAuthenticationStartResponse:(NSDictionary *)response {

    self = [super init];

    if (self) {
        
        [self setNonce:response[@"nonce"]];
        [self setProvider:response[@"provider"]];
        [self setAuthenticationID:response[@"authenticationId"]];
        [self setNonceRequired:[response[@"nonceRequired"] boolValue]];

    }

    return self;
}


- (NSDictionary *)parameters {

    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];

    [parameters dnSetObject:[self provider] forKey:@"provider"];
    [parameters dnSetObject:[self authenticationID] forKey:@"authenticationId"];

    return parameters;

}

@end
