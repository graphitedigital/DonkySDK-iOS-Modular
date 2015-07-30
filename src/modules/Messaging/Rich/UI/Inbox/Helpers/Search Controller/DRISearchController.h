//
//  DRISearchController.h
//  RichInbox
//
//  Created by Chris Watson on 03/06/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DRIDataController.h"
#import "DRLogicMainController.h"

@interface DRISearchController : NSObject <UISearchDisplayDelegate, UISearchBarDelegate>

/*!
 The search controller for the inbox view, this passes the search phrase
 to the Rich Inbox Data controller so that the table view can be updated.
 
 @param inboxDataController the controller for the inbox, this is responsible for 
 providing the data for the table view.
 
 @return a new DRISearchController
 
 @since 2.2.2.7
 */
- (instancetype)initWithTableViewDataController:(DRIDataController *)inboxDataController;

@end
