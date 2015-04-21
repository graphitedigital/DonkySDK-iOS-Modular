//
//  DCUIRMessageViewController.m
//  RichPopUp
//
//  Created by Chris Watson on 13/04/2015.
//  Copyright (c) 2015 Chris Watson. All rights reserved.
//

#import "DCUIRMessageViewController.h"
#import "UIView+AutoLayout.h"
#import "DNRichMessage.h"
#import "DCUILocalization+Localization.h"

@interface DCUIRMessageViewController ()
@property(nonatomic, strong) DNRichMessage *richMessage;
@property(nonatomic, strong) UIPopoverController *shareButtonPopOver;
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

- (void)createUI {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:DCUILocalizedString(@"close_button_title", nil)                                                                             style:UIBarButtonItemStyleDone target:self action:@selector(closeView:)];

    if ([[self richMessage] body]) {
        UIWebView *webView = [UIWebView autoLayoutView];
        [webView loadHTMLString:[[self richMessage] body] baseURL:nil];
        [[self view] addSubview:webView];
        [webView pinToSuperviewEdges:JRTViewPinAllEdges inset:0.0];
    }
}

- (void)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if ([[self delegate] respondsToSelector:@selector(messageWasClosed:)]) {
            [[self delegate] messageWasClosed:[[self richMessage] messageID]];
        }
    }];
}

- (UINavigationController *)richPopUpNavigationControllerWithModalPresentationStyle:(UIModalPresentationStyle) presentationStyle {
    if ([[self richMessage] body]) {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];
        if (presentationStyle)
            [navigationController setModalPresentationStyle:presentationStyle];

        return navigationController;
    }
    return nil;
}

@end
