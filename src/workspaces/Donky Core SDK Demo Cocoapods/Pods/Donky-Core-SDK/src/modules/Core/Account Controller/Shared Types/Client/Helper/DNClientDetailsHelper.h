//
//  DNClientDetailsHelper.h
//  Core Container
//
//  Created by Chris Watson on 17/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DNClientDetailsHelper : NSObject

+ (NSString *)sdkVersion;

+ (NSMutableDictionary *)moduleVersions;

+ (void)saveModuleVersions:(NSMutableDictionary *)moduleVersions;

@end
