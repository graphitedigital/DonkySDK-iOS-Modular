//
//  DLSTargetUser.m
//  Location Services
//
//  Created by Donky Networks on 22/10/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DLSTargetUser.h"

@interface DLSTargetUser ()
@property (nonatomic, readwrite) NSString *networkProfileID;
@property (nonatomic, readwrite) NSString *userID;
@end

@implementation DLSTargetUser

- (instancetype)initWithUserID:(NSString *)userID networkProfileID:(NSString *)networkProfileID { 
    
    self = [super init];
    
    if (self) {
        [self setUserID:userID];
        [self setNetworkProfileID:networkProfileID];
    }

    return self;
}

@end