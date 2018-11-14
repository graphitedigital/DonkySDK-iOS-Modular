//
//  DCUIAlertHelper.m
//  RichInbox
//
//  Created by Donky Networks on 07/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DCUIAlertHelper.h"
#import <Donky_Core_SDK/DNSystemHelpers.h>
#import "DCUILocalization+Localization.h"

@implementation DCUIAlertHelper

+ (void)showAlertViewWithDelegate:(id)delegate title:(NSString *)title message:(NSString *)message okayButton:(NSString *)okayTitle okayHandler:(SEL)selector textField:(BOOL)textField {

    if (!okayTitle) {
        okayTitle = DCUILocalizedString(@"common_ui_generic_ok");
    }

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

+ (void)showButtonAlertWithDelegate:(id)delegate title:(NSString *)title message:(NSString *)message firstButton:(NSString *)firstTitle secondButton:(NSString *)secondTitle firstHandler:(SEL)firstHandler secondHandler:(SEL)secondHandler textField:(BOOL)textField {

    if ([DNSystemHelpers systemVersionAtLeast:8.0]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        if (textField) {
            [alertController addTextFieldWithConfigurationHandler:nil];
        }
        
        
        [alertController addAction:[UIAlertAction actionWithTitle:firstTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if ([delegate respondsToSelector:firstHandler]) {
                ((void (*)(id, SEL))[delegate methodForSelector:firstHandler])(delegate, firstHandler);
            }
        }]];

        [alertController addAction:[UIAlertAction actionWithTitle:secondTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if ([delegate respondsToSelector:secondHandler]) {
                ((void (*)(id, SEL, UIAlertController *))[delegate methodForSelector:secondHandler])(delegate, secondHandler, alertController);
            }
        }]];
        
        [delegate presentViewController:alertController animated:YES completion:nil];
    }
    
    else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:firstTitle, secondTitle, nil];
        if (textField) {
            [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        }
        [alertView show];
    }
}

@end
