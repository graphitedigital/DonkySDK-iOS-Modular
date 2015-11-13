//
//  UIResponder+FirstResponder.h
//  Donky Demo
//
//  Created by Donky Networks on 19/08/2014.
//  Copyright (c) 2014 Dynmark. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIResponder (FirstResponder)

+ (id)currentFirstResponder;

+ (void)closeResponder;

@end
