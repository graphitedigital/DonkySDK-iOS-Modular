//
//  DRITableViewCellHelper.m
//  RichInbox
//
//  Created by Donky Networks on 05/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DRITableViewCellHelper.h"
#import <Donky_CommonMessaging_UI/DCUIAvatarImageView.h>
#import "UIView+AutoLayout.h"
#import <Donky_CommonMessaging_UI/NSDate+DCMDate.h>
#import "DRUIThemeConstants.h"
#import <Donky_CommonMessaging_UI/DCUILocalization+Localization.h>
#import <Donky_CommonMessaging_UI/DCUIMainController.h>
#import <Donky_CommonMessaging_UI/DCUIConstants.h>

@implementation DRITableViewCellHelper

+ (UIImageView *)avatarImageViewTheme:(DRUITheme *)theme {
    DCUIAvatarImageView *imageView = [[DCUIAvatarImageView alloc] initWithBorderColour:[theme colourForKey:kDRUInboxCellAvatarBorderColour]];
    [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    return imageView;
}

+ (UILabel *)textLabelWithNumberOfLines:(NSInteger)numberOfLines lineBreakMode:(NSLineBreakMode)lineBreakMode textAlignment:(NSTextAlignment)alignment {
    UILabel *textLabel = [UILabel autoLayoutView];
    [textLabel setNumberOfLines:numberOfLines];
    [textLabel setTextAlignment:alignment];
    [textLabel setLineBreakMode:lineBreakMode];
    return textLabel;
}

+ (NSString *)dateWithMessage:(DNRichMessage *)richMessage {

    NSDate *sentDate = [richMessage sentTimestamp];

    return [sentDate donkyRelativeString];
}

+ (UIView *)topContentView {
    UIView *topContent = [UIView autoLayoutView];
    return topContent;
}

+ (UIButton *)moreButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTranslatesAutoresizingMaskIntoConstraints:NO];
    [button setHidden:YES];
    return button;
}

+ (DCUINewBannerView *)bannerView {
    DCUINewBannerView *newView = [[DCUINewBannerView alloc] initWithText:DCUILocalizedString(@"common_messaging_new_banner_text")];
    [newView setTranslatesAutoresizingMaskIntoConstraints:NO];
    return newView;
}

+ (CGFloat)messageHeight:(NSString *)messageText theme:(DCUITheme *)theme cellWidth:(CGRect)cellFrame editMode:(BOOL)editMode {
    CGFloat stringHeight = [DCUIMainController sizeForString:messageText
                                                 font:[theme fontForKey:kDRUIInboxCellDescriptionFont]
                                            maxHeight:CGFLOAT_MAX
                                             maxWidth:(cellFrame.size.width - (kDCUIAvatarHeightWithTenPixelInsets * (editMode ? 1.5f : 1.0f)))].height;
    stringHeight += 10;

    if (editMode) {
        CGFloat minimumHeight = kDCUIAvatarHeightWithTenPixelInsets;
        if (stringHeight < minimumHeight) {
            return minimumHeight;
        }
    }
    return stringHeight;
}

@end
