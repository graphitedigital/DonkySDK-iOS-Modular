//
//  DCUIBannerView.h
//  Push UI Container
//
//  Created by Chris Watson on 15/03/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCUIBannerView : UIView

/*!
 The message label on the Donky Banner View
 
 @since 2.0.0.0
 */
@property(nonatomic, readonly) UILabel *messageLabel;

/*!
 The avatar image view, containing the Avatar image.
 
 @since 2.0.0.0
 */
@property(nonatomic, readonly) UIImageView *avatarImageView;

/*!
 The button view, this is used for interactive notifications, nil if no buttons present.
 
 @since 2.0.0.0
 */
@property(nonatomic, strong) UIView *buttonView;

/*!
 Initialiser method for a new banner view, containing all the details that need to be displayed
 to the user.
 
 @param displayName the display name of the sender of the message.
 @param body        the body of the message to dispaly.
 @param sentTime    the time that the message was sent, this is formatted in a relative time stamp.
 @param assetId     the avatar ID, this is used to populate the image view.
 @param type        the type of message that is being dispalyed, i.e. simple push/rich etc...
 @param messageID   the ID of the message that is being represented by the banner view.
 
 @return a new instance of a Banner View.
 
 @since 2.0.0.0
 */
- (instancetype)initWithSenderDisplayName:(NSString *)displayName body:(NSString *)body messageSentTime:(NSDate *)sentTime avatarAssetID:(NSString *)assetId notificationType:(NSString *)type messageID:(NSString *)messageID;

/*!
 Used to add a tap gesture recogniser to the view, call this to ensure that the banner responds to
 user tap events.
 
 @since 2.0.0.0
 */
- (void)configureGestures;

/*!
 Helper method to load a defualt avatar image..
 
 @since 2.4.3.1
 */
- (void)loadDefaultAvatar;

@end
