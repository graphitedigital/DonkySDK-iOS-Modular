//
//  DCUIMainController.m
//  PushUI
//
//  Created by Chris Watson on 11/04/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import "DCUIMainController.h"

@implementation DCUIMainController

+ (CGSize)sizeForString:(NSString *)text font:(UIFont *)font maxHeight:(CGFloat)maxHeight maxWidth:(CGFloat)maxWidth {

    if (!font) //If no font is supplied then we default:
        font = [UIFont systemFontOfSize:12];

    NSDictionary *stringAttributes = @{NSFontAttributeName : font};

    CGSize stringLength = [text boundingRectWithSize:CGSizeMake(maxWidth, maxHeight)
                                             options:NSStringDrawingTruncatesLastVisibleLine |
                                                     NSStringDrawingUsesLineFragmentOrigin
                                          attributes:stringAttributes context:nil].size;
    return stringLength;
}

+ (void)addGestureToView:(UIView *)view withDelegate:(id)delegate withSelector:(SEL)customSelector {
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:delegate action:customSelector];
    [view addGestureRecognizer:panGestureRecognizer];
    [panGestureRecognizer setDelegate:delegate];
}

@end
