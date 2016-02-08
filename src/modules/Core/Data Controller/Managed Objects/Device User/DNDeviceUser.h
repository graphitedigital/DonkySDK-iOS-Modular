//
//  DNDeviceUser.h
//  Core Container
//
//  Created by Donky Networks on 16/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DNUser.h"

@interface DNDeviceUser : DNUser

@property (nonatomic, retain) NSNumber * isAnonymous;

@property (nonatomic, retain) NSNumber * isDeviceUser;

@property (nonatomic, retain) NSDate * lastUpdated;

@end
