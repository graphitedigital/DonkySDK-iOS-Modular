//
//  DCUINewBannerView.m
//  RichInbox
//
//  Created by Donky Networks on 08/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

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

        [self setBottomConstraint:[self pinAttribute:NSLayoutAttributeBottom toSameAttributeOfItem:[self textLabel] withConstant:10]];

    }

    return self;

}

@end
