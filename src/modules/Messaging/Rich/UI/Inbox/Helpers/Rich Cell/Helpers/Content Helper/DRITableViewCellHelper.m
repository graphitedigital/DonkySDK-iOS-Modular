//
//  DRITableViewCellHelper.m
//  RichInbox
//
//  Created by Chris Watson on 05/06/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import "DRITableViewCellHelper.h"
#import "DCUIAvatarImageView.h"
#import "UIView+AutoLayout.h"
#import "NSDate+DCMDate.h"
#import "DRUIThemeConstants.h"
#import "DRichMessage+Localization.h"
#import "DCUIMainController.h"
#import "DCUIConstants.h"

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
    [button setImage:[UIImage imageNamed:@"donky_more_icon.png"] forState:UIControlStateNormal];
    return button;
}

+ (DCUINewBannerView *)bannerView {
    DCUINewBannerView *newView = [[DCUINewBannerView alloc] initWithText:DRichMessageLocalizedString(@"rich_inbox_new_banner_text")];
    [newView setTranslatesAutoresizingMaskIntoConstraints:NO];
    return newView;
}

+ (CGFloat)messageHeight:(NSString *)messageText theme:(DCUITheme *)theme cellWidth:(CGRect)cellFrame editMode:(BOOL)editMode {
    CGFloat stringHeight = [DCUIMainController sizeForString:messageText
                                                 font:[theme fontForKey:kDRUIInboxCellDescriptionFont]
                                            maxHeight:CGFLOAT_MAX
                                             maxWidth:(cellFrame.size.width - (kDCUIAvatarHeightWithTenPixelInsets * (editMode ? 1.5 : 1)))].height;
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
