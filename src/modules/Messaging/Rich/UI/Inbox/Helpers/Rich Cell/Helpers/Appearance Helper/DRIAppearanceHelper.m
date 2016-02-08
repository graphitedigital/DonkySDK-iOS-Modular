//
//  DRIAppearanceHelper.m
//  RichInbox
//
//  Created by Donky Networks on 27/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DRIAppearanceHelper.h"

@implementation DRIAppearanceHelper

+ (void)setReadAppearance:(UILabel *)titleLabel description:(UILabel *)descriptionLabel dateLabel:(UILabel *)dateLabel bannerView:(DCUINewBannerView *)bannerView theme:(DRUITheme *)theme {

    [titleLabel setTextColor:[theme colourForKey:kDRUIInboxReadTitleColour]];
    [descriptionLabel setTextColor:[theme colourForKey:kDRUIInboxReadDescriptionColour]];
    [dateLabel setTextColor:[theme colourForKey:kDRUIInboxReadDateColour]];
    [bannerView setHidden:YES];

}

@end
