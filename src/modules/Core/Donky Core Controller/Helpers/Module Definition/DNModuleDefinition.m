//
//  DNModuleDefinition.m
//  Core Container
//
//  Created by Chris Watson on 18/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

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
