//
//  DCUIAlertHelper.h
//  RichInbox
//
//  Created by Donky Networks on 07/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCUIAlertHelper : NSObject

+ (void)showAlertViewWithDelegate:(id)delegate title:(NSString *)title message:(NSString *)message okayButton:(NSString *)okayTitle okayHandler:(SEL)selector textField:(BOOL)textField;

+ (void)showButtonAlertWithDelegate:(id)delegate title:(NSString *)title message:(NSString *)message firstButton:(NSString *)buttonTitle secondButton:(NSString *)secondTitle firstHandler:(SEL)firstHandler secondHandler:(SEL)secondHandler textField:(BOOL)textField;

@end
