//
//  DCUISplitViewController.h
//  RichInbox
//
//  Created by Donky Networks on 03/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCUISplitViewController : UISplitViewController <UISplitViewControllerDelegate>

/*!
 Initialise method to create a new split view controller with the supplied view controllers.
 
 @param masterView the view controller that should be the master view.
 @param detailView the view controller that should be the detail view.
 
 @return a new instance of a split view controller.
 
 @since 2.2.2.7
 */
- (instancetype)initWithMasterView:(UIViewController *)masterView detailViewController:(UIViewController *)detailView;

/*!
 The master view controller in this split view.
 
 @since 2.2.2.7
 */
@property (nonatomic, strong) UINavigationController *masterViewController;

/*!
 The detail view controller in the split view.
 
 @since 2.2.2.7
 */
@property (nonatomic, strong) UINavigationController *detailViewController;

@end
