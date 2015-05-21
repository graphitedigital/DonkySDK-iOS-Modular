//
//  DCUIRMessageViewController.h
//  RichPopUp
//
//  Created by Chris Watson on 13/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DNRichMessage;

/*!
 The delegate used to alert delegates when the rich message view was closed. Use to perform additioanl logic once the user has closed the current rich message.
 
 @since 2.0.0.0
 */
@protocol DCUIRMessageViewControllerDelegate <NSObject>

/*!
 Method invoked when the view controller is dismissed.

 @param messageID the message ID of the Rich Message currently being displayed.

 @since 2.0.3.6
 */
- (void)richMessagePopUpWasClosed:(NSString *)messageID;

@optional

/*!
 Method invoked when the view controller is dismissed.
 
 @param messageID the message ID of the Rich Message currently being displayed.
 
 @since 2.0.0.0
 */
- (void)messageWasClosed:(NSString *)messageID __attribute__((deprecated("deprecated, please use richMessagePopUpWasClosed")));

@end

@interface DCUIRMessageViewController : UIViewController <UIPopoverControllerDelegate>

/*!
 The Delegate which should respond to events when the message was closed.
 
 @since 2.0.0.0
 */
@property (nonatomic, weak) id <DCUIRMessageViewControllerDelegate> delegate;

/*!
 Initialiser method to create a new View Controller with the supplied rich message.
 
 @param richMessage the rich message that should be used to populate this view.
 
 @return a new UIViewController with the rich message.
 
 @since 2.0.0.0
 */
- (instancetype)initWithRichMessage:(DNRichMessage *)richMessage;

/*!
 Helper method to return a new UINavigationController containing the Rich Message in a view controller.
 
 @param presentationStyle the presentation style that the navigation controller should use.
 
 @return a new UINavigationController with it's view set to the current Rich Message view.
 
 @since 2.0.0.0
 */
- (UINavigationController *)richPopUpNavigationControllerWithModalPresentationStyle:(UIModalPresentationStyle)presentationStyle;

@end
