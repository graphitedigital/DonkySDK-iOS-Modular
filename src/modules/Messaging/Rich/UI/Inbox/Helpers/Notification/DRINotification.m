//
//  DRINotification.m
//  RichInbox
//
//  Created by Chris Watson on 16/06/2015.
//  Copyright © 2015 Chris Wunsch. All rights reserved.
//

#import "DRINotification.h"
#import "DNServerNotification.h"

@interface DRINotification ()

@end

@implementation DRINotification

- (instancetype)initWithServerNotification:(DNServerNotification *)notification {

    self = [super initWithNotification:notification customBody:[self objectForKey:@"description" inNotification:notification]];

    if (self) {


    }

    return self;
}

@end

