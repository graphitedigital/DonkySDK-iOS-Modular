//
//  DRIDataController.h
//  RichInbox
//
//  Created by Donky Networks on 03/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "DRITableViewCell.h"
#import "DNRichMessage.h"
#import "DRLogicMainController.h"
#import "DNLocalEvent.h"
#import "DRUITheme.h"
#import "DRLFetchedResultsController.h"

@class DRLFetchedResultsController;

@protocol DRIDataControllerDelegate <NSObject>

@required

- (void)richInboxMessageSelected:(DNRichMessage *)richMessage;

- (void)endRefreshingWithSuccess:(BOOL)success;

- (void)moreButtonTappedForRichMessage:(DNRichMessage *)richMessage atIndexPath:(NSIndexPath *)indexPath senderFrame:(CGRect)senderFrame;

- (void)messagesSelected:(BOOL)selected;

- (void)updateUI;

- (void)toggleEditMode;

- (void)searchDidStart;

- (void)searchDidEnd;

- (void)updateTabBarCount;

@end

@interface DRIDataController : NSObject <UITableViewDataSource, UITableViewDelegate, DRITableViewCellDelegate, NSFetchedResultsControllerDelegate, DRLFetchedResultsControllerDelegate>

@property (nonatomic, weak) id <DRIDataControllerDelegate> delegate;

- (instancetype)initWithTableView:(UITableView *)tableView theme:(DRUITheme *)theme;

- (DNRichMessage *)richMessageAtRow:(NSInteger)indexPathRow;

- (NSInteger)indexOfMessage:(DNRichMessage *)richMessage;

- (NSInteger)richMessageCount;

- (NSNumber *)unreadRichMessageCount;

- (BOOL)toggleAllSelectedMessages;

- (void)checkForNewRichMessages;

- (void)createLocalEventHandlers;

- (void)removeLocalEventHandlers;

- (void)searchTableView:(NSString *)searchString;

- (void)resetSearch;

- (void)deleteAllSelectedMessages;

- (void)enterEditMode:(BOOL)enterEditMode;

- (void)deleteRichMessage:(DNRichMessage *)richMessage;

- (void)selectFirstRow;

- (void)unselectCurrentCell;

- (void)deleteMessageAtIndex:(NSInteger)index;

- (void)closeAllCells;

- (void)searchDidStart;

- (void)searchDidEnd;

- (void)deleteAllExpiredMessages;

- (void)hideSearchBar;

@end
