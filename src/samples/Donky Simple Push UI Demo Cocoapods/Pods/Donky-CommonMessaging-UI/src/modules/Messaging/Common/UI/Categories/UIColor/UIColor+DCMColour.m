//
//  UIColor+DCMColour.m
//  ChatUI
//
//  Created by Donky Networks on 20/08/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import "UIColor+DCMColour.h"

@implementation UIColor (DCMColour)

- (NSString *)hexStringFromColor
{
    const CGFloat *components = CGColorGetComponents(self.CGColor);

    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];

    return [NSString stringWithFormat:@"%02lX%02lX%02lX",
                                      lroundf(r * 255),
                                      lroundf(g * 255),
                                      lroundf(b * 255)];
}

@end
