//
//  DNLocalEvent.m
//  Core Container
//
//  Created by Donky Networks on 18/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DNLocalEvent.h"

@interface DNLocalEvent ()
@property(nonatomic, readwrite) NSString *eventType;
@property(nonatomic, readwrite) NSDate *timeStamp;
@property(nonatomic, readwrite) NSString *publisher;
@property(nonatomic, readwrite) id data;
@end

@implementation DNLocalEvent

- (instancetype)initWithEventType:(NSString *)eventType publisher:(NSString *)publisher timeStamp:(NSDate *)timeStamp data:(id)data {

    self = [super init];
    
    if (self) {
        self.eventType = eventType;
        self.timeStamp = timeStamp;
        self.publisher = publisher;
        self.data = data;
    }

    return self;
}

@end
