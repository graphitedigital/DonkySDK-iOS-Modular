//
//  DNEventSubscriber.h
//  Core Container
//
//  Created by Chris Watson on 17/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DNLocalEvent.h"
#import "DNBlockDefinitions.h"

@interface DNEventSubscriber : NSObject

- (void)subscribeToLocalEvent:(NSString *)eventType handler:(DNLocalEventHandler)handler;

- (void)unSubscribeToLocalEvent:(NSString *)eventType handler:(DNLocalEventHandler)handler;

- (void)publishEvent:(DNLocalEvent *)event;

@end
