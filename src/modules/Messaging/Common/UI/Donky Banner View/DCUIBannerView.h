//
//  DCUIBannerView.h
//  Push UI Container
//
//  Created by Chris Watson on 15/03/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCUIBannerView : UIView

@property(nonatomic, readonly) UILabel *messageLabel;

@property(nonatomic, readonly) UIImageView *avatarImageView;

- (instancetype)initWithSenderDisplayName:(NSString *)displayName body:(NSString *)body messageSentTime:(NSDate *)sentTime avatarAssetID:(NSString *)assetId;

- (void)configureGestures;

@end
