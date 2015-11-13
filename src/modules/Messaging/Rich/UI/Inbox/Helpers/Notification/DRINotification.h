//
//  DRINotification.h
//  RichInbox
//
//  Created by Donky Networks on 16/06/2015.
//  Copyright © 2015 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCUINotification.h"

@interface DRINotification : DCUINotification

- (instancetype)initWithServerNotification:(DNServerNotification *)notification;

@end
