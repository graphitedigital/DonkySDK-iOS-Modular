//
//  DCUINewBannerView.m
//  RichInbox
//
//  Created by Chris Watson on 08/06/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import "DCUINewBannerView.h"
#import "UIView+AutoLayout.h"

@implementation DCUINewBannerView

- (instancetype)initWithText:(NSString *)text {

    self = [super init];

    if (self) {

        [self setTextLabel:[UILabel autoLayoutView]];
        [[self textLabel] setTextAlignment:NSTextAlignmentCenter];
        [[self textLabel] setText:text];

        [self addSubview:[self textLabel]];

        [[self textLabel] centerInView:self];

        [self pinAttribute:NSLayoutAttributeBottom toSameAttributeOfItem:[self textLabel] withConstant:10];

    }

    return self;

}

@end
