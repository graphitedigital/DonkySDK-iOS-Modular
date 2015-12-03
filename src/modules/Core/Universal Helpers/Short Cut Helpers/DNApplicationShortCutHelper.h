//
//  DNApplicationShortCutHelper.h
//  ChatUI
//
//  Created by Donky Networks on 03/10/2015.
//  Copyright © 2015 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>

@interface DNApplicationShortCutHelper : NSObject

/*!
 Class method to handle the input from when a user interacts with an application short cut item. Iphone 6S(+) only.
 
 @param application       the application which received the short cut item.
 @param shortcutItem      the shortcut item itself.
 @param completionHandler the completion handler to be invoked when completed.
 
 @since 2.6.5.4
 */
+ (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler;

@end
