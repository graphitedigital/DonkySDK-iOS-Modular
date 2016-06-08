//
//  DRUITheme.h
//  RichInbox
//
//  Created by Donky Networks on 05/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCUITheme.h"

@interface DRUITheme : DCUITheme

/*!
 Initialiser method to create a new theme for the Rich Inbox
 
 @return a new instance
 
 @since 2.2.2.7
 */
- (instancetype)init;

/*!
 Initialiser method to create a new theme using the Donky Default values.
 
 @return a new instance of the theme controller.
 
 @since 2.2.2.7
 */
- (instancetype)initWithDefaultTheme;

@end
