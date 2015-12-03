//
//  DNRetryObject.h
//  Core Container
//
//  Created by Donky Networks on 21/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNRequest.h"

@interface DNRetryObject : NSObject

@property (nonatomic) NSUInteger numberOfRetries;

@property (nonatomic) NSUInteger sectionRetries;

@property (nonatomic, readonly) DNRequest *request;

- (instancetype)initWithRequest:(DNRequest *)request;

- (void)incrementRetryCount;

- (void)incrementSection;

@end
