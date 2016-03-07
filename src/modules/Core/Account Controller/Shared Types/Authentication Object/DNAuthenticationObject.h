//
//  DNAuthenticationObject.h
//  DonkyMaster
//
//  Created by Chris Wunsch on 26/02/2016.
//  Copyright © 2016 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DNAuthenticationObject : NSObject

@property (nonatomic, readonly) NSString *expectedUserID;

@property (nonatomic, readonly) NSString *nonce;

- (instancetype)initWithUserID:(NSString *)userID nonce:(NSString *)nonce;

@end
