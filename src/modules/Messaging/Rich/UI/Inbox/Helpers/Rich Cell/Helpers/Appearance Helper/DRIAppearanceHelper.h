//
//  DRIAppearanceHelper.h
//  RichInbox
//
//  Created by Donky Networks on 27/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Donky_CommonMessaging_UI/DCUINewBannerView.h>
#import "DRUITheme.h"
#import "DRUIThemeConstants.h"

@interface DRIAppearanceHelper : NSObject

+ (void)setReadAppearance:(UILabel *)titleLabel description:(UILabel *)descriptionLabel dateLabel:(UILabel *)dateLabel bannerView:(DCUINewBannerView *)bannerView theme:(DRUITheme *)theme;

@end
