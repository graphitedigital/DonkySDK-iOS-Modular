//
//  DCUIAvatarImageView.h
//  RichInbox
//
//  Created by Donky Networks on 05/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCUIAvatarImageView : UIImageView

/*!
 Initialiser to create a new UIImageView for the SDKs avatars.
 
 @param borderColour the colour of the avatars border.
 
 @return a new DCUIAvatarImageView
 
 @since 2.2.2.7
 */
- (instancetype)initWithBorderColour:(UIColor *)borderColour;

/*!
 Helper methd to enable dynamically changing the border colour.
 
 @param color the colour that it should be.
 
 @since 2.6.5.4
 */
- (void)setBorderColour:(UIColor *)color;

@end
