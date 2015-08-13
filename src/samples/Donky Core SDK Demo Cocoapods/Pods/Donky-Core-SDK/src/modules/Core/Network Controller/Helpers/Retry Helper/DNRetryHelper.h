//
//  DNRetryHelper.h
//  Core Container
//
//  Created by Chris Watson on 21/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DNRequest;

@interface DNRetryHelper : NSObject

- (void)retryRequest:(DNRequest *)request task:(NSURLSessionDataTask *)task;

@end
