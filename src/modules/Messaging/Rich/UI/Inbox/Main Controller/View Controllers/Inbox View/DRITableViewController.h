//
//  DRITableViewController.h
//  RichInbox
//
//  Created by Donky Networks on 03/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRIDataController.h"
#import "DRIDataController.h"
#import "DRISearchController.h"
#import "DRIOptionsView.h"
#import "DRUITheme.h"
#import "DRIMessageViewController.h"

@interface DRITableViewController : UITableViewController <DRIDataControllerDelegate, DRIOptionsViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, DRMessageViewControllerDelegate>

/*!
 Helper method to delete a rich message. This is called from the action sheets.
 
 @param richMessage the rich message to be deleted.
 
 @since 2.2.2.7
 */
- (void)deleteMessage:(DNRichMessage *)richMessage;

/*!
 Helper method to delete all the expired messages in the database
 
 @since 2.2.2.7
 */
- (void)deleteAllExpiredMessages;

/*!
 Helper method to share a rich message. This is called from the action sheets.
 
 @param richMessage the rich message that should be shared.
 
 @since 2.2.2.7
 */
- (void)shareRichMessage:(DNRichMessage *)richMessage;

/*!
 Helper method to update the badge count on the tab bar controller icon.
 
 @since 2.5.4.3
 */
- (void)updateTabBarCount;

/*!
 Helper method to determine if the left bar button should be enabled, this should be set to true
 if you are presenting this view modally, allowing it to be dismissed.
 
 @param enable whether the left bar button done item should be added to the current navigation controller.
 
 @since 2.2.2.7
 */
- (void)enableLeftBarDoneButton:(BOOL)enable;

@end
