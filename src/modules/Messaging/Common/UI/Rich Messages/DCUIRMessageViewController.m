//
//  DCUIRMessageViewController.m
//  RichPopUp
//
//  Created by Chris Watson on 13/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DCUIRMessageViewController.h"
#import "UIView+AutoLayout.h"
#import "DNRichMessage.h"
#import "DCUILocalization+Localization.h"
#import "NSDate+DNDateHelper.h"

@interface DCUIRMessageViewController ()
@property(nonatomic, strong) DNRichMessage *richMessage;
@end

@implementation DCUIRMessageViewController

- (instancetype)initWithRichMessage:(DNRichMessage *)richMessage {

    self = [super init];

    if (self) {

        [self setRichMessage:richMessage];

        [self setTitle:[[self richMessage] title]];

        [self createUI];

    }

    return self;
}

- (NSString *) richMessageContent {

    if (![[self richMessage] expiryTimestamp])
        return [[self richMessage] body];

    //Figure out expiration:
    NSDate *currentDate = [NSDate date];

    NSDate *expirationDate = [[self richMessage] expiryTimestamp];

    NSString *richMessageContent = nil;

    if ([expirationDate isDateBeforeDate:currentDate])
        richMessageContent = [[self richMessage] expiredBody];
    else
        richMessageContent = [[self richMessage] body];

    return richMessageContent;

}

- (void)createUI {

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:DCUILocalizedString(@"close_button_title", nil) style:UIBarButtonItemStyleDone target:self action:@selector(closeView:)];

    NSString *richMessageContent = [self richMessageContent];

    if (richMessageContent) {
        UIWebView *webView = [UIWebView autoLayoutView];
        [webView loadHTMLString:richMessageContent baseURL:nil];
        [[self view] addSubview:webView];
        [webView pinToSuperviewEdges:JRTViewPinAllEdges inset:0.0];
    }
}

- (void)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if ([[self delegate] respondsToSelector:@selector(richMessagePopUpWasClosed:)]) {
            [[self delegate] richMessagePopUpWasClosed:[[self richMessage] messageID]];
        }
    }];
}

- (UINavigationController *)richPopUpNavigationControllerWithModalPresentationStyle:(UIModalPresentationStyle) presentationStyle {

    NSString *richMessageContent = [self richMessageContent];

    if (richMessageContent) {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];
        if (presentationStyle)
            [navigationController setModalPresentationStyle:presentationStyle];

        return navigationController;
    }
    return nil;
}

@end
