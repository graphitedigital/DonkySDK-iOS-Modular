//
//  DNRetryObject.m
//  Core Container
//
//  Created by Donky Networks on 21/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

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
