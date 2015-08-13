//
//  DRINotification.h
//  RichInbox
//
//  Created by Chris Watson on 16/06/2015.
//  Copyright © 2015 Chris Wunsch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCUINotification.h"

@interface DRINotification : DCUINotification

- (instancetype)initWithServerNotification:(DNServerNotification *)notification;

@end
