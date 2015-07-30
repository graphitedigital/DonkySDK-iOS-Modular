//
//  DRIAppearanceHelper.h
//  RichInbox
//
//  Created by Chris Watson on 27/06/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DCUINewBannerView.h"
#import "DRUITheme.h"
#import "DRUIThemeConstants.h"

@interface DRIAppearanceHelper : NSObject

+ (void)setReadAppearance:(UILabel *)titleLabel description:(UILabel *)descriptionLabel dateLabel:(UILabel *)dateLabel bannerView:(DCUINewBannerView *)bannerView theme:(DRUITheme *)theme;

@end
