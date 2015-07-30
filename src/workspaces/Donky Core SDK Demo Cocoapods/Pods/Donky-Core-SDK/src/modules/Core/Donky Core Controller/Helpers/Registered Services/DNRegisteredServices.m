//
//  DNRegisteredServices.m
//  Core Container
//
//  Created by Chris Watson on 18/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNRegisteredServices.h"

@interface DNRegisteredServices ()
@property(nonatomic, strong) NSMutableDictionary *registeredServices;
@end

@implementation DNRegisteredServices

- (instancetype)init {

    self = [super init];
    
    if (self) {
        [self setRegisteredServices:[[NSMutableDictionary alloc] init]];
    }

    return self;
}

- (void)registerService:(NSString *)type instance:(id)instance {
    [self registeredServices][type] = instance;
}

- (void)unRegisterService:(NSString *) type {
    [[self registeredServices] removeObjectForKey:type];
}

- (id)serviceForType:(NSString *)type {
    return [self registeredServices][type];
}

@end
