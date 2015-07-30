//
//  DNModuleHelper.m
//  Donky Network SDK Container
//
//  Created by Chris Watson on 06/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "NSDate+DNDateHelper.h"
#import "DNModuleHelper.h"
#import "DNModuleDefinition.h"
#import "DNSubscription.h"
#import "DNLoggingController.h"

@implementation DNModuleHelper

+ (void)addModule:(DNModuleDefinition *)module toModuleList:(NSMutableDictionary *)moduleList subscription:(DNSubscription *)subscription {
    if (![[moduleList allKeys] containsObject:[subscription notificationType]]) {
        (moduleList)[[subscription notificationType]] = [[NSMutableDictionary alloc] init];
    }
    if (![[moduleList[[subscription notificationType]] allKeys] containsObject:[module name]]) {
        [moduleList[[subscription notificationType]] setObject:subscription forKey:[module name]];
    }
    else {
        DNInfoLog(@"Module %@ is already subscriped to %@", [module name], [subscription notificationType]);
    }
}

+ (void)removeModule:(DNModuleDefinition *)module toModuleList:(NSMutableDictionary *)moduleList subscription:(DNSubscription *)subscription {
    if ([[moduleList[[subscription notificationType]] allKeys] containsObject:[module name]]) {
        [moduleList[[subscription notificationType]] removeObjectForKey:[module name]];
    }
}

+ (BOOL)isModuleRegistered:(NSMutableArray *)modules moduleName:(NSString *)moduleName moduleVersion:(NSString *)moduleVersion {
    __block BOOL isKnown = NO;
    [modules enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DNModuleDefinition *moduleDefinition = obj;
        if ([[moduleDefinition name] isEqualToString:moduleName]) {
            //We need to compare versions:
            NSMutableArray *suppliedVersion = [[moduleVersion componentsSeparatedByString:@"."] mutableCopy];
            NSMutableArray *originalVersion = [[[moduleDefinition version] componentsSeparatedByString:@"."] mutableCopy];

            [DNModuleHelper padArray:suppliedVersion];
            [DNModuleHelper padArray:originalVersion];

            __block BOOL minimumVersionMet = NO;

            [originalVersion enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx2, BOOL *stop2) {

                NSInteger originalValue = [obj2 integerValue];
                NSInteger comparatorValue = [suppliedVersion[idx2] integerValue];

                if (comparatorValue > originalValue) {
                    *stop2 = YES;
                }
                else if (idx2 == [originalVersion count] - 1) {
                    minimumVersionMet = YES;
                }
            }];

            if (minimumVersionMet)
                isKnown = YES;
            else
                DNErrorLog(@"Module %@ is known but the version number supplied %@ is different from known version %@", moduleName, moduleVersion, [moduleDefinition version]);
            *stop = YES;
        }
    }];

    return isKnown;
}

+ (void)padArray:(NSMutableArray *)suppliedVersion {
    NSInteger missingDigits = 4 - [suppliedVersion count];
    for (int i = 0; i < missingDigits; i++) {
        [suppliedVersion addObject:@"0"];
    }
}

@end
