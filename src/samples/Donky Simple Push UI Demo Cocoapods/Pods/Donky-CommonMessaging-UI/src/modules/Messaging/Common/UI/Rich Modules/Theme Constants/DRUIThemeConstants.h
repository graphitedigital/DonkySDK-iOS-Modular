//
//  DRUIThemeConstants.h
//  RichInbox
//
//  Created by Donky Networks on 05/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 The name of the rich inbox theme, use this to retrieve the correct 
 theme from the theme controller shared instance.
 
 @since 2.2.2.7
 */
extern NSString *const kDRUIThemeName;

/*!
 The colour of the rich inbox 'new' message banner view.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUIInboxNewBannerColour;

/*!
 THe colour of the text that's inside the rich inbox 'new' message banner view.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUInboxNewBannerTextColour;

/*!
 The colour of selected cells in the rich message inbox view.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUInboxCellSelectedColour;

/*!
 The colour of the cell separator in the rich message inbox view.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUInboxCellSeparatorColour;

/*!
 The background colour of the rich message inbox view when
 there are no messages to display.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUIInboxNoMessagesBackgroundColour;

/*!
 The colour of the 'No messages' text in the rich message inbox
 view when there are no messages.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUIInboxNoMessagesTextColour;

/*!
 The colour of the cells in the rich message inbox view when
 they are not selected.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUIInboxCellBackgroundColour;

/*!
 The colour of the 'more' button in the rich message inbox view. 
 This is the button with the three dots, that is displayed when the user swipes
 the cell to the left.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUIInboxCellMoreButtonColour;

/*!
 The font of the title in the rich message inbox view cell. This is 
 the sender display name.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUIInboxCellTitleFont;

/*!
 The font of the description text in the rich message inbox view.
 This is positioned directly under the title text and is populated
 with the rich message description.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUIInboxCellDescriptionFont;

/*!
 The font that is used for the text in the rich message inbox view options.
 This is the view that appears when the inbox enters edit mode. It animates
 up from the bottom and allows the user to perform actions on multiple items.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUIInboxOptionsViewFont;

/*!
 The font of the date label in the rich message inbox view. This is
 positioned in the top right of the cells. The date test is relative to the sent date
 using the following rules:
 
 Sent in the last 5 minutes : "just now"
 Sent more than 5 minutes ago but less than 1 hour: "x min ago"
 Sent more than 1 hour and was sent yesterday : "yesterday"
 Sent more than 1 hour ago but was not yesterday and less than 24 hours  : "x hours ago"
 Sent more than 24 hours ago but less than 1 week ago : "mon,tues,wed,thur,fri,sat or sun"
 Sent more than 1 week ago : "12/12/12"
 
 @since 2.2.2.7
 */
extern NSString * const kDRUIInboxCellDateFont;

/*!
 The colour of the title text in the rich message inbox view when the 
 message has not been read.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUIInboxUnreadTitleColour;

/*!
 The colour of the title text in the rich message inbox view when the 
 message has been read.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUIInboxReadTitleColour;

/*!
 The colour of the description text in the rich message inbox view
 when the message has not been read.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUIInboxUnreadDescriptionColour;

/*!
 The colour of the description text in the rich message inbox view
 when the message has been read.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUIInboxReadDescriptionColour;

/*!
 The colour of the date label in the rich message inbox view when
 the message has not been read.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUIInboxUnreadDateColour;

/*!
 The colour of the date label in the rich message inbox view when the 
 message has been read.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUIInboxReadDateColour;

/*!
 The colour of the text in the options view in the rich message
 inbox view when the option is enabled.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUIInboxOptionsEnabledTextColour;

/*!
 The colour of the text in the options view in the rich message
 inbox view when the option is disabled.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUIInboxOptionsDisabledTextColour;

/*!
 The background colour of the options view in the rich message
 inbox view.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUIInboxOptionsBackgroundColour;

/*!
 The colour of the option divider in the options view in
 the rich message inbox view (only present when there are more than two options).
 
 @since 2.2.2.7
 */
extern NSString * const kDRUIInboxOptionsDividerColour;

/*!
 The font used for the 'No messages' label in the rich message inbox view.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUIInboxNoMessagesFont;

/*!
 The font used for the text in the 'New' banner in the rich 
 message inbox view.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUIInboxNewBannerFont;

/*!
 The image to be used in the rich message inbox view when it is being
 edited and the user highlights a message.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUIInboxSelectionTickUnHighlighted;

/*!
 The image to be used in the rich message inbox view when it is being
 edited and the cell is 'un-highlighted'.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUIInboxSelectionTickHighlighted;

/*!
 The image to be used in the rich message inbox view when it is being
 edited and the user selects a message.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUIInboxSelectionTickSelected;

/*!
 The image to be used in the rich message inbox view when it is being
 edited and the user de-selects a message.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUIInboxSelectionTickUnSelected;

/*!
 The colour of the search bar tint in the rich message inbox view.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUIInboxSearchBarTintColour;

/*!
 The colour of the search tint in the rich message inbox view.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUIInboxSearchTintColour;

/*!
 The colour of the avatar border in the rich message inbox view.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUInboxCellAvatarBorderColour;

/*!
 The colour of the refresh control in the rich message inbox view.
 
 @since 2.2.2.7
 */
extern NSString * const kDRUIInboxRefreshControlTintColour;

/*!
 The image for an unread rich message, this is used if there is no avatar and as a place
 holder while the avatar is downloade.d
 
 @since 2.6.5.4
 */
extern NSString * const kDRUIInboxDefaultAvatarClosedImage;

/*!
 The read avatar for rich messages, used if no avatar is avaible or while the avatar is 
 being downloaded.
 
 @since 2.6.5.4
 */
extern NSString * const kDRUIInboxDefaultAvatarOpenImage;

/*!
 The image used for the tab bar, if the rich inbox views are inside a tab bar controller.
 
 @since 2.6.5.4
 */
extern NSString * const kDRUIInboxIconImage;

/*!
 The image used for a selected tab bar icon, if the inbox is inside a tab bar controller.
 
 @since 2.6.5.4
 */
extern NSString * const kDRUIInboxSelectedIconImage;

/*!
 The more button that is revealed as the user swipes the inbox cell to the left.
 
 @since 2.6.5.4
 */
extern NSString * const kDRUIInboxMoreButtonImage;

/*!
 The button in the navigation bar that allows the user to enter edit mode

 @since 2.6.5.4
 */
extern NSString * const kDRUIInboxSelectAllNavigationButtonImage;







