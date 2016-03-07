//
//  DNAuthenticationObject.m
//  DonkyMaster
//
//  Created by Chris Wunsch on 26/02/2016.
//  Copyright © 2016 Donky Networks. All rights reserved.
//

#import "DNAuthenticationObject.h"

@interface DNAuthenticationObject ()
@property (nonatomic, readwrite) NSString *expectedUserID;
@property (nonatomic, readwrite) NSString *nonce;
@end

@implementation DNAuthenticationObject

- (instancetype)initWithUserID:(NSString *)userID nonce:(NSString *)nonce {

    self = [super init];

    if (self) {
        [self setExpectedUserID:userID];
        [self setNonce:nonce];
    }

    return self;
}


@end
