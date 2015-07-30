//
//  DNDeviceUser.h
//  Core Container
//
//  Created by Chris Watson on 16/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DNUser.h"

@interface DNDeviceUser : DNUser

@property (nonatomic, retain) NSNumber * isAnonymous;

@property (nonatomic, retain) NSNumber * isDeviceUser;

@end
