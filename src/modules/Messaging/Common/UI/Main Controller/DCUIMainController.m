//
//  DCUIMainController.m
//  PushUI
//
//  Created by Donky Networks on 11/04/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import "DCUIMainController.h"

@implementation DCUIMainController

+ (CGSize)sizeForString:(NSString *)text font:(UIFont *)font maxHeight:(CGFloat)maxHeight maxWidth:(CGFloat)maxWidth {

    if (!font) {
        font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    }

    NSDictionary *stringAttributes = @{NSFontAttributeName : font};

    CGSize stringLength = [text boundingRectWithSize:CGSizeMake(maxWidth, maxHeight)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:stringAttributes context:nil].size;
    return stringLength;
}

+ (CGSize)sizeForAttributedString:(NSAttributedString *)text maxHeight:(CGFloat)maxHeight maxWidth:(CGFloat)maxWidth {
    CGSize stringLength = [text boundingRectWithSize:CGSizeMake(maxWidth, maxHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    return stringLength;
}

+ (NSAttributedString *)attributedText:(NSString *)text highLightedValue:(NSString *)highlighted normalFont:(UIFont *)normalFont highlightedFont:(UIFont *)highlightedFont highLightedColour:(UIColor *)colour {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttribute:NSFontAttributeName value:normalFont range:NSMakeRange(0, text.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:colour range:[text rangeOfString:highlighted]];
    [attributedString addAttribute:NSFontAttributeName value:highlighted range:[text rangeOfString:highlighted]];
    return attributedString;
}

+ (void)addGestureToView:(UIView *)view withDelegate:(id)delegate withSelector:(SEL)customSelector {
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:delegate action:customSelector];
    [view addGestureRecognizer:panGestureRecognizer];
    [panGestureRecognizer setDelegate:delegate];
}

@end
