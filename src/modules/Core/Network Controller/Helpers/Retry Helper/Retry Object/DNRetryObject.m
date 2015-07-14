//
//  DNRetryObject.m
//  Core Container
//
//  Created by Chris Watson on 21/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNRetryObject.h"

@interface DNRetryObject ()
@property(nonatomic, readwrite) DNRequest *request;
@end

@implementation DNRetryObject

- (instancetype)initWithRequest:(DNRequest *)request {

    self = [super init];
    
    if (self) {

        [self setNumberOfRetries:0];
        [self setSectionRetries:0];
        [self setRequest:request];
        
    }

    return self;
}

- (void) incrementRetryCount {
    NSUInteger retries = [self numberOfRetries];
    retries += 1;
    [self setNumberOfRetries:retries];
}

- (void)incrementSection {
    NSUInteger retries = [self sectionRetries];
    retries += 1;
    [self setSectionRetries:retries];
    [self setNumberOfRetries:0];
}

@end
