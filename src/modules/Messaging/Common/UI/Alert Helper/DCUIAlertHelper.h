//
//  DCUIAlertHelper.h
//  RichInbox
//
//  Created by Chris Watson on 07/06/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCUIAlertHelper : NSObject

/*!
 Helper method to show an alert view. This will use the most apporpriate 
 APIs depending on the current OS.
 
 @param delegate  the delegate for the alert view, used for iOS 7 APIs.
 @param title     the title of the alert view.
 @param message   the message for the alert view.
 @param okayTitle the title fo the okay button.
 @param selector  the selector to use when the okay button is tapped on iOS 8.0
 @param textField whether a text field should be added to the alert.
 
 @since 2.2.2.7
 */
+ (void)showAlertViewWithDelegate:(id)delegate title:(NSString *)title message:(NSString *)message okayButton:(NSString *)okayTitle okayHandler:(SEL)selector textField:(BOOL)textField;

@end
