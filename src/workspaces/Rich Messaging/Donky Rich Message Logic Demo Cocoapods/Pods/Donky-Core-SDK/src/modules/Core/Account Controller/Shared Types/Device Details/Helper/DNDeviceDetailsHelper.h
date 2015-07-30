//
//  DNDeviceDetailsHelper.h
//  Core Container
//
//  Created by Chris Watson on 16/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DNDeviceDetailsHelper : NSObject

+ (NSString *)deviceType;

+ (NSString *)deviceModel;

+ (NSString *)operatingSystem;

+ (NSString *)osVersion;

+ (NSString *)deviceName;

+ (NSDictionary *)additionalProperties;

+ (void)saveDeviceType:(NSString *)deviceType;

+ (void)saveDeviceName:(NSString *)deviceName;

+ (void)saveAdditionalProperties:(NSDictionary *)additionalProperties;

@end
