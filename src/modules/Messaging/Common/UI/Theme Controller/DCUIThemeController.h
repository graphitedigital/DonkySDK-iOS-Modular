//
//  DCUIThemeController.h
//  RichInbox
//
//  Created by Chris Watson on 03/06/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCUITheme.h"

@interface DCUIThemeController : NSObject

/*!
 The shared instance for the SDK theme.
 
 @return a new instance
 
 @since 2.2.2.7
 */
+(DCUIThemeController *)sharedInstance;

/*!
 Method to add a theme to the shared instance. To customise the Donky UI, please create a new DCUITheme, apply it's porperties 
 and then add the theme using this method.
 
 @param theme the theme that should be added to the Controller.
 
 @since 2.2.2.7
 */
- (void)addTheme:(DCUITheme *)theme;

/*!
 Method to retrieve a theme from the controller.
 
 @param themeName the name of the theme that should be returned.
 
 @return the theme, nil if there is no theme with that name.
 
 @since 2.2.2.7
 @see DCUITheme
 */
- (DCUITheme *)themeForName:(NSString *)themeName;

@end
