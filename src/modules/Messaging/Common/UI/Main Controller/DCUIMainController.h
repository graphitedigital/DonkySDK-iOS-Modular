//
//  DCUIMainController.h
//  PushUI
//
//  Created by Chris Watson on 11/04/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DCUIMainController : NSObject

+ (CGSize)sizeForString:(NSString *)text font:(UIFont *)font maxHeight:(CGFloat)maxHeight maxWidth:(CGFloat)maxWidth;

+ (void)addGestureToView:(UIView *)view withDelegate:(id)delegate withSelector:(SEL)customSelector;

@end
