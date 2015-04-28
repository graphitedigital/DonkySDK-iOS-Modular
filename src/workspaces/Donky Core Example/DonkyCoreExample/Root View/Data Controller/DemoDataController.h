//
//  DemoDataController.h
//  DonkyCoreExample
//
//  Created by Chris Watson on 27/04/2015.
//  Copyright (c) 2015 Chris Watson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DemoDataController : NSObject


- (instancetype)initWithColourView:(UIView *)view;

- (void)sendColourMessage:(UIColor *)colour;

- (void)sync;
@end
