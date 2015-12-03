//
//  DNRegisteredServices.h
//  Core Container
//
//  Created by Donky Networks on 18/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DNRegisteredServices : NSObject

- (instancetype) init;

- (void)registerService:(NSString *)type instance:(id)instance;

- (void)unRegisterService:(NSString *)type;

- (id)serviceForType:(NSString *)type;

@end
