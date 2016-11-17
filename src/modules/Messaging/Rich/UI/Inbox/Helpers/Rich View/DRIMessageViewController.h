//
//  DRIMessageViewController.h
//  RichPopUp
//
//  Created by Donky Networks on 13/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Donky_RichMessage_Logic/DNRichMessage.h>
#import <Donky_CommonMessaging_Logic/DCMConstants.h>

/*!
 The delegate used to alert delegates when the rich message view was closed. Use to perform additional logic once the user has closed the current rich message.
 
 @since 2.0.0.0
 */
@protocol DRMessageViewControllerDelegate <NSObject>

@optional

/*!
 Method invoked when the view controller is dismissed.

 @param messageID the message ID of the Rich Message currently being displayed.

 @since 2.0.3.6
 */
- (void)richMessagePopUpWasClosed:(NSString *)messageID;

/*!
 Method invoked when the view controller is dismissed.
 
 @param messageID the message ID of the Rich Message currently being displayed.
 
 @since 2.0.0.0
 */
- (void)messageWasClosed:(NSString *)messageID __attribute__((deprecated("Please use richMessagePopUpWasClosed - 2.2.2.7")));

@end

@interface DRIMessageViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate, UIWebViewDelegate>

/*!
 The Delegate which should respond to events when the message was closed.
 
 @since 2.0.0.0
 */
@property (nonatomic, weak) id <DRMessageViewControllerDelegate> delegate;

/*!
 Boolean to determine whether the the split view controller should hide the master view
 when in portrait.
 
 @since 2.2.2.7
 */
@property (nonatomic, readonly, getter=shouldHideViewController) BOOL hideViewController;

/*!
 The property for the detail view, this changes the content of the message view when it's being used
 in a split view controller.
 
 @since 2.2.2.7
 */
@property (nonatomic, strong) DNRichMessage *detailItem;

/*!
 Initialiser method to create a new View Controller with the supplied rich message.
 
 @param richMessage the rich message that should be used to populate this view.
 
 @return a new UIViewController with the rich message.
 
 @since 2.0.0.0
 */
- (instancetype)initWithRichMessage:(DNRichMessage *)richMessage;

/*!
 Method to add the expanding button, this is used only for the iPhone 6+ when it's in landscape mode.
 
 @since 2.4.3.1
 */
- (void)addExpandingButton;

/*!
 Helper method to return a new UINavigationController containing the Rich Message in a view controller.
 
 @param presentationStyle the presentation style that the navigation controller should use.
 
 @return a new UINavigationController with it's view set to the current Rich Message view.
 
 @since 2.0.0.0
 */
- (UINavigationController *)richPopUpNavigationControllerWithModalPresentationStyle:(UIModalPresentationStyle)presentationStyle;

/*!
 Helper method to customise the bar button items

 @param buttonItem the button item to use
 @param rightSide whether the button should be placed on the right side

 @since 2.0.0.0
 */
- (void)setBarButtonItem:(UIBarButtonItem *)buttonItem isRighSide:(BOOL)rightSide __attribute__((deprecated("Please use addBarButtonItem:buttonSide instead - 2.2.2.7")));

- (void)addBarButtonItem:(UIBarButtonItem *)buttonItem buttonSide:(DonkyMessageViewBarButtonSide)side;

/*!
 Helper method to remove a bar button item from the navigation controller
 
 @param buttonItem the button item to be removed
 @param side       the side on which the button item is located.
 
 @since 2.2.2.7
 */
- (void)removeBarButtonItem:(UIBarButtonItem *)buttonItem buttonSide:(DonkyMessageViewBarButtonSide)side;

/*!
 Helper method to determine whether the views content should be enabled. This is used
 when the message forms part of a Split View Controller paradigm, such as with iPads and iPhone 6+.
 When disabled, the webView's alpha is set to 0.5, user interaction is disabled and the right navigation item is disabled
 (this is the share message option).
 
 @param isEditing YES to disable all content, NO to enable.
 
 @since 2.2.2.7
 */
- (void)toggleEnabled:(BOOL)isEnabled;

@end
