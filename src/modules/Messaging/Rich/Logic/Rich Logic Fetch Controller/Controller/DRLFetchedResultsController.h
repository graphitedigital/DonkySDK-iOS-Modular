//
//  DRLFetchedResultsController.h
//  RichInbox
//
//  Created by Chris Watson on 24/07/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@protocol DRLFetchedResultsControllerDelegate <NSObject>

/*!
 Delegate method for new items have been inserted
 
 @param indexPaths an array of index paths for the new items.
 
 @since 2.4.3.1
 */
- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths;

/*!
 Delegate method for when an item has been removed.
 
 @param indexPath the indexPath of the item being removed.
 
 @since 2.4.3.1
 */
- (void)deleteRowsAtIndexPath:(NSIndexPath *)indexPath;

/*!
 Delegate method for when an item has been reloaded i.e. in response to a change
 of the object model.
 
 @param indexPaths the index paths of the items that have been updated.
 
 @since 2.4.3.1
 */
- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths;

@end

/*!
 Helper class to managed the fetched results controller for Rich Messages.
 */
@interface DRLFetchedResultsController : NSObject <NSFetchedResultsControllerDelegate>

/*!
 Initialiser method to create a new instance of DRLFetchedResultsController with a UITableViewController.
 
 @param tableView the table view which should use the fetchedResultsController.
 
 @return a new instance of a fetch results controller.
 
 @since 2.4.3.1
 */
- (instancetype)initWithTableView:(UITableView *)tableView;

/*!
 The delegate object for the fetched results controller.
 
 @since 2.4.3.1
 */
@property (nonatomic, weak) id <DRLFetchedResultsControllerDelegate> delegate;

/*!
 The fetched results controller, used by the table view delegate to attain information about it's contents.
 
 @since 2.4.3.1
 */
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

/*!
 Boolean to determine and set if the table view is in search mode, when it is, a different predicate should be used.
 
 @since 2.4.3.1
 */
@property (nonatomic, getter=isSearching) BOOL searching;

/*!
 The string that holds the search when in search mode. This is used for the predicate when searching the fethced results controller.
 
 @since 2.4.3.1
 */
@property (nonatomic, strong) NSString *searchString;

@end
