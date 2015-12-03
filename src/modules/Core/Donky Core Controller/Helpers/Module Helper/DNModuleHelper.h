//
//  DNModuleHelper.h
//  Donky Network SDK Container
//
//  Created by Donky Networks on 06/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DNSubscription.h"
#import "DNModuleDefinition.h"

@interface DNModuleHelper : NSObject

+ (void)addModule:(DNModuleDefinition *)module toModuleList:(NSMutableDictionary *)moduleList subscription:(DNSubscription *)subscription;

+ (void)removeModule:(DNModuleDefinition *)module toModuleList:(NSMutableDictionary *)moduleList subscription:(DNSubscription *)subscription;

+ (BOOL)isModuleRegistered:(NSMutableArray *)modules moduleName:(NSString *)moduleName moduleVersion:(NSString *)moduleVersion;

@end
