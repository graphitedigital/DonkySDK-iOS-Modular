//
//  DRITableViewCell.h
//  RichInbox
//
//  Created by Chris Watson on 03/06/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DNRichMessage.h"
#import "DRICellPanGestureHelper.h"
#import "DRUITheme.h"

@class DRITableViewCell;

/*!
 The delegate object for the table view cell, this is in charge of affecting
 settings in the main table view, as well as when the more button has been tapped.
 
 @since 2.2.2.7
 */
@protocol DRITableViewCellDelegate <NSObject>

/*!
 Method invoked when a cells more button was tapped. The button is passed
 along with this method.
 
 @param sender the button that was repsonsible for invoking the method. This is
 passed so that the cell responsible can be identified.
 
 @since 2.2.2.7
 */
- (void)cellButtonWasTapped:(UIButton *)sender;

/*!
 Method to determine whether the tableview scrolling should be disabled.
 Table view scrolling is disabled when the user is swiping the cell left or right.
 
 @param disable whether it should be disabled or now.
 @param cell    the cell that is being swiped.
 
 @since 2.2.2.7
 */
- (void)shouldDisableScroll:(BOOL)disable leaveCells:(DRITableViewCell *)cell;

/*!
 Method to report whether a cell was opened or closed. Opened cells are kept track of 
 so that only one cell can be opened at once.
 
 @param cell      the cell that's being opened.
 @param wasOpened whether the cell was opened or closed.
 
 @since 2.2.2.7
 */
- (void)cell:(DRITableViewCell *)cell wasOpened:(BOOL)wasOpened;

/*!
 Method to report when a rich message has suddenly expired.
 
 @param cell the cell which contains the expired rich message.
 
 @since 2.2.2.7
 */
- (void)messageExpired:(UITableViewCell *)cell;

@end

@interface DRITableViewCell : UITableViewCell <DRICellPanGestureHelperDelegate>

/*!
 The delegate for the cell, used for reporting when a cell was opened/closed, when the 'more button' was tapped
 and whether the tableview should stop being scrollable.
 
 @since 2.2.2.7
 */
@property (weak) id <DRITableViewCellDelegate> delegate;

/*!
 Wether the table view is currently in edit mode.
 
 @since 2.2.2.7
 */
@property (nonatomic, getter=istableViewEditing) BOOL tableViewEditing;

/*!
 The theme to be used when creating this cell.
 
 @since 2.2.2.7
 */
@property(nonatomic, strong) DRUITheme *theme;

/*!
 The rich message for this cell.
 
 @since 2.2.2.7
 */
@property (nonatomic, strong) DNRichMessage *richMessage;

/*!
 Method to configure the current cell.
 
 @since 2.2.2.7
 */
- (void)configureCell;

/*!
 Method to close the current cell.
 
 @since 2.2.2.7
 */
- (void)closeCell;

/*!
 Helper method to refresh the layout of the table view description, this is largely 
 used when going in and out of edit mode.
 
 @since 2.4.3.1
 */
- (void)resetLayouts;
@end
