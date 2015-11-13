//
//  DNClientDetails.h
//  Core Container
//
//  Created by Donky Networks on 17/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DNClientDetails : NSObject

@property(nonatomic, readonly) NSString *currentLocalTime;

@property(nonatomic, readonly) NSString *appVersion;

@property(nonatomic, readonly) NSString *sdkVersion;

@property(nonatomic, readonly) NSMutableDictionary *moduleVersions;

- (void)saveModuleVersions:(NSMutableDictionary *)moduleVersions;

- (NSDictionary *)parameters;

@end
