//
//  DNModuleDefinition.m
//  Core Container
//
//  Created by Donky Networks on 18/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DNModuleDefinition.h"

@interface DNModuleDefinition ()
@property(nonatomic, readwrite) NSString *version;
@property(nonatomic, readwrite) NSString *name;
@end

@implementation DNModuleDefinition

- (instancetype)initWithName:(NSString *)name version:(NSString *)version {

    self = [super init];

    if (self) {

        [self setName:name];

        if (!version) {
            version = @"1.0.0.0";
        }

        [self setVersion:version];

    }

    return self;
}

@end
