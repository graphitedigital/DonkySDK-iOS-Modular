//
//  DNDeviceUser.m
//  Core Container
//
//  Created by Donky Networks on 16/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DNDeviceUser.h"

@implementation DNDeviceUser

@dynamic isAnonymous;
@dynamic isDeviceUser;
@dynamic lastUpdated;

@end
