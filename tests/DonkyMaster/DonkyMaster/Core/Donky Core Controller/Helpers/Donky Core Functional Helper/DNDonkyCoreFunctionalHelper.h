//
//  DNDonkyCoreFunctionalHelper.h
//  DonkyCore
//
//  Created by Chris Watson on 28/04/2015.
//  Copyright (c) 2015 Chris Watson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DNServerNotification;

@interface DNDonkyCoreFunctionalHelper : NSObject

+ (void)handleNewDeviceMessage:(DNServerNotification *)notification;

@end
