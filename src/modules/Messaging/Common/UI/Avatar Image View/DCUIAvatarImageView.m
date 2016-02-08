//
//  DCUIAvatarImageView.m
//  RichInbox
//
//  Created by Donky Networks on 05/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DCUIAvatarImageView.h"
#import "DCUIConstants.h"

@implementation DCUIAvatarImageView

- (instancetype)initWithBorderColour:(UIColor *)borderColour {

    self = [super init];

    if (self) {

        [[self layer] setCornerRadius:kDCUIAvatarHeight / 2.0f];
        [[self layer] setMasksToBounds:YES];
        [[self layer] setBorderWidth:0.50];

        [self setBorderColour:borderColour];
    }

    return self;
}

- (void)setBorderColour:(UIColor *)color {
    [[self layer] setBorderColor:[color CGColor]];
}

@end
