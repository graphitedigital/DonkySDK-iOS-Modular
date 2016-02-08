//
//  DNUser.m
//  DonkyCore
//
//  Created by Donky Networks on 08/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DNUser.h"

@implementation DNUser

@dynamic additionalProperties;
@dynamic avatarAssetID;
@dynamic countryCode;
@dynamic displayName;
@dynamic emailAddress;
@dynamic mobileNumber;
@dynamic selectedTags;
@dynamic userID;
@dynamic firstName;
@dynamic lastName;
@dynamic networkProfileID;

@end
