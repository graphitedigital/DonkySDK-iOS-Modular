//
//  DNRequest.h
//  Donky Network SDK Container
//
//  Created by Donky Networks on 11/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNNetworkController.h"

@class DNNetworkController;

@interface DNRequest : NSObject

@property (nonatomic, readonly, getter=isSecure) BOOL secure;

@property (nonatomic, readonly) NSString *route;

@property (nonatomic, readonly) DonkyNetworkRoute method;

@property (nonatomic, readonly) NSDictionary *parameters;

@property (nonatomic, readonly) DNNetworkSuccessBlock successBlock;

@property (nonatomic, readonly) DNNetworkFailureBlock failureBlock;

@property (nonatomic) NSInteger numberOfAttempts;

- (instancetype)initWithSecure:(BOOL)secure route:(NSString *)route httpMethod:(DonkyNetworkRoute)method parameters:(NSDictionary *)parameters success:(DNNetworkSuccessBlock)successBlock failure:(DNNetworkFailureBlock)failureBlock;

@end
