//
//  DNRegisteredServices.m
//  Core Container
//
//  Created by Donky Networks on 18/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

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
