//
//  DRITableViewCellHelper.h
//  RichInbox
//
//  Created by Chris Watson on 05/06/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DNRichMessage.h"
#import "DRUITheme.h"
#import "DCUINewBannerView.h"

@interface DRITableViewCellHelper : NSObject

+ (UIImageView *)avatarImageViewTheme:(DRUITheme *)theme;

+ (UILabel *)textLabelWithNumberOfLines:(NSInteger)numberOfLines lineBreakMode:(NSLineBreakMode)lineBreakMode textAlignment:(NSTextAlignment)alignment;

+ (NSString *)dateWithMessage:(DNRichMessage *)richMessage;

+ (UIView *)topContentView;

+ (UIButton *)moreButton;

+ (DCUINewBannerView *)bannerView;

+ (CGFloat)messageHeight:(NSString *)messageText theme:(DCUITheme *)theme cellWidth:(CGRect)cellFrame editMode:(BOOL)editMode;

@end
