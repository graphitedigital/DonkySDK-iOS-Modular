//
//  UIViewController+DPUIViewController.h
//  Push UI Container
//
//  Created by Donky Networks on 16/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 UIViewController categroy.
 
 @since 2.0.0.0
 */
@interface UIViewController (DNRootViewController)

/*!
 Method to get the applications root view controller, this is used in several modules when presneting alert views/internal banners.
 
 @return the current root view controller of the application
 
 @since 2.0.0.0
 */
+ (UIViewController *)applicationRootViewController;

@end
