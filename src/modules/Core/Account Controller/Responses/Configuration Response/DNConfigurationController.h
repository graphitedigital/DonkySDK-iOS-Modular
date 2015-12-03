//
//  DNConfigurationController.h
//  Core Container
//
//  Created by Donky Networks on 20/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DNConfigurationController : NSObject

+ (void)saveConfiguration:(NSDictionary *)configuration;

+ (NSDictionary *)buttonSets;

+ (NSDictionary *)standardContacts;

+ (NSDictionary *)configuration;

+ (NSMutableSet *)buttonsAsSets;

+ (id)objectFromConfiguration:(NSString *)string;

+ (void)saveConfigurationObject:(id)object forKey:(NSString *)key;

+ (CGFloat)maximumContentByteSize;

+ (CGFloat)maximumSignalRByteSize;

+ (NSInteger)richMessageAvailabilityDays;

@end
