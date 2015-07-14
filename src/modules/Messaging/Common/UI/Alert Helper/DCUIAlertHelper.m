//
//  DCUIAlertHelper.m
//  RichInbox
//
//  Created by Chris Watson on 07/06/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import "DCUIAlertHelper.h"
#import "DNSystemHelpers.h"
#import "DCUILocalization+Localization.h"

@implementation DCUIAlertHelper

+ (void)showAlertViewWithDelegate:(id)delegate title:(NSString *)title message:(NSString *)message okayButton:(NSString *)okayTitle okayHandler:(SEL)selector textField:(BOOL)textField {

    if (!okayTitle)
        okayTitle = DCUILocalizedString(@"common_ui_generic_ok");

    if ([DNSystemHelpers systemVersionAtLeast:8.0]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        if (textField)
            [alertController addTextFieldWithConfigurationHandler:nil];

        [alertController addAction:[UIAlertAction actionWithTitle:DCUILocalizedString(@"common_ui_generic_cancel") style:UIAlertActionStyleCancel handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:okayTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if ([delegate respondsToSelector:selector]) {
                ((void (*)(id, SEL))[delegate methodForSelector:selector])(delegate, selector);
            }
        }]];

        [delegate presentViewController:alertController animated:YES completion:nil];
    }

    else {

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:DCUILocalizedString(@"common_ui_generic_cancel")
                                                  otherButtonTitles:okayTitle, nil];
        if (textField)
            [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];

        [alertView show];
    }

}


@end
