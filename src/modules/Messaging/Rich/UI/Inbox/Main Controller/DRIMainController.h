//
//  DRIMainController.h
//  RichInbox
//
//  Created by Donky Networks on 12/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DRLogicMainController.h"
#import "DCUISplitViewController.h"
#import "DRITableViewController.h"
#import "DCUIBannerView.h"

@interface DRIMainController : NSObject

/*!
 Bool to determine if the rich inbox should display a banner view when a new 
 rich message is received. This is the internal banner view and is never displayed
 if the inbox or the message view is currently being viewed.
 
 Default value is true.
 
 @since 2.2.2.7
 */
@property (nonatomic, getter=shouldShowBannerView) BOOL showBannerView;

/*!
 Whether the rich message controller should load the rich message in a full screen modal
 style when the user taps the banner view. 
 
 Default value is true.
 
 @since 2.2.2.7
 */
@property (nonatomic, getter=shouldLoadTappedMessage) BOOL loadTappedMessage;

/*!
 The modal presentation style of the message view when it's being presented modally. 
 This is only needed if the loadTappedMessage is set to true.
 
 Default value is UIModalPresentationFormSheet
 
 @since 2.2.2.7
 */
@property (nonatomic) UIModalPresentationStyle iPadModelPresentationStyle;

/*!
 The rich logic controller that should be used to perform/access rich message
 helper methods. You should try and not to initialise your own.
 
 @since 2.2.2.7
 */
@property(nonatomic, strong) DRLogicMainController *richLogicController;

/*!
 Singleton instance to hold the module.
 
 @return a new instance
 
 @since 2.2.2.7
 */
+ (DRIMainController *)sharedInstance;

/*!
 Start the Inbox Main Controller.
 
 @since 2.2.2.7
 */
- (void)start;

/*!
 Method ot stop the Rich Inbox main controller. This un-registers the
 local events and notification subscriptions.
 
 @since 2.2.2.7
 */
- (void)stop;

/*!
 Helper method to return a navigation controller with the rich inbox table view. This should be used for
 iPhones (use richInboxSplitViewController for iPhone 6+).
 
 @return a new navigation controller with a DRITableViewController as the root view.
 
 @since 2.2.2.7
 */
- (UINavigationController *)richInboxTableViewWithNavigationController __attribute__((deprecated("Please use class method of same signature - 2.5.4.3")));

+ (UINavigationController *)richInboxTableViewWithNavigationController;

/*!
 Helper method to return a new DRITableViewController object.
 
 @return a new rich inbox table view controller.
 
 @since 2.2.2.7
 */
- (DRITableViewController *)richInboxTableViewController __attribute__((deprecated("Please use class method of same signature - 2.5.4.3")));

+ (DRITableViewController *)richInboxTableViewController;

/*!
 Helper method to return a new split view controller. This should be used for 
 iPads and optionally, iPhone 6+.
 
 @return a new split view controller with a master and detail view controller.
 
 @since 2.2.2.7
 */
- (DCUISplitViewController *)richInboxSplitViewController __attribute__((deprecated("Please use class method of same signature - 2.5.4.3")));

+ (DCUISplitViewController *)richInboxSplitViewController;

/*!
 Helper method to retrieve a usable view for the rich inbox no matter what device is being used. This is
 helpful when making universal apps and a split view is desired.
 
 @return a new DCUISplitViewController OR UINavigationController with the rich inbox set.
 
 @since 2.4.3.1
 */
- (UIViewController *)universalRichInboxViewController __attribute__((deprecated("Please use class method of same signature - 2.5.4.3")));

+ (UIViewController *)universalRichInboxViewController;

/*!
 Helper method to add a left bar button item to the rich inbox, this button will dismiss 
 itself if it is a modal view.
 
 @param viewController the Navigation controller that should have the button added to it.
 
 @since 2.4.3.1
 */
- (void)enableLeftBarDoneButtonForViewController:(id)viewController;

@end
