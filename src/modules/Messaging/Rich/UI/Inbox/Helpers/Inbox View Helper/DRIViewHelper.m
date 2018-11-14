//
//  DRIViewHelper.m
//  RichInbox
//
//  Created by Donky Networks on 07/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DRIViewHelper.h"
#import "UIView+AutoLayout.h"
#import <Donky_Core_SDK/DNSystemHelpers.h>
#import <Donky_CommonMessaging_UI/DRichMessage+Localization.h>
#import <Donky_CommonMessaging_UI/DCUILocalization+Localization.h>
#import <Donky_RichMessage_Logic/DNRichMessage+DNRichMessageHelper.h>

@implementation DRIViewHelper

+ (void)presentCellActionSheet:(DRITableViewController *)viewController withMessage:(DNRichMessage *)richMessage atIndexPath:(NSIndexPath *)indexPath senderFrame:(CGRect)senderFrame {

    if ([DNSystemHelpers systemVersionAtLeast:8.0]) {

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:DCUILocalizedString(@"common_ui_generic_options")
                                                                                 message:[richMessage messageDescription]
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];


        if ([richMessage canBeShared]) {
            [alertController addAction:[UIAlertAction actionWithTitle:DRichMessageLocalizedString(@"rich_inbox_share_button_title")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                [viewController shareRichMessage:richMessage];
            }]];
        }

        [alertController addAction:[UIAlertAction actionWithTitle:DCUILocalizedString(@"common_ui_generic_delete")
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction *action) {
            [viewController deleteMessage:richMessage];
        }]];

        [alertController addAction:[UIAlertAction actionWithTitle:DCUILocalizedString(@"common_ui_generic_cancel")
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil]];

        if ([DNSystemHelpers isDeviceIPad] || [DNSystemHelpers isDeviceSixPlusLandscape]) {

            UIPopoverPresentationController *popover = alertController.popoverPresentationController;

            if (popover) {
                popover.sourceView = viewController.view;
                popover.sourceRect = senderFrame;
                popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
            }
        }

        [viewController presentViewController:alertController animated:YES completion:nil];
        
    }

    else {

        BOOL showShare = [richMessage canBeShared];

        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%@\n%@", DCUILocalizedString(@"common_ui_generic_options"), [richMessage messageDescription]]
                                                                 delegate:viewController
                                                        cancelButtonTitle:DCUILocalizedString(@"common_ui_generic_cancel")
                                                   destructiveButtonTitle:DCUILocalizedString(@"common_ui_generic_delete")
                                                        otherButtonTitles:showShare ? DRichMessageLocalizedString(@"rich_inbox_share_button_title") : nil, nil];
        [actionSheet setTag:indexPath.row];

        if ([DNSystemHelpers isDeviceIPad]) {
            [actionSheet showFromRect:senderFrame inView:[viewController view] animated:YES];
        }
        else {
            [actionSheet showInView:viewController.view];
        }
    }
}

+ (DRIOptionsView *)optionsViewForView:(DRITableViewController *)viewController {
    DRIOptionsView *optionsView = [[DRIOptionsView alloc] init];
    [optionsView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [optionsView setDelegate:viewController];

    [[[viewController tableView] superview] addSubview:optionsView];

    [optionsView pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0];
    [optionsView constrainToHeight:50];

    return optionsView;
}

+ (void)showDeleteAlert:(DRITableViewController *)viewController richMessage:(DNRichMessage *)richMessage selectedIndex:(NSInteger)index {
    if ([DNSystemHelpers systemVersionAtLeast:8.0]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:DCUILocalizedString(@"common_ui_message_expired_title")
                                                                                 message:DCUILocalizedString(@"common_ui_message_expired_message")
                                                                          preferredStyle:UIAlertControllerStyleAlert];

        [alertController addAction:[UIAlertAction actionWithTitle:DCUILocalizedString(@"common_ui_generic_delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [viewController deleteMessage:richMessage];
        }]];

        [alertController addAction:[UIAlertAction actionWithTitle:DCUILocalizedString(@"common_ui_generic_delete_all") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [viewController deleteAllExpiredMessages];
        }]];

        [viewController presentViewController:alertController animated:YES completion:nil];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:DCUILocalizedString(@"common_ui_message_expired_title")
                                                            message:DCUILocalizedString(@"common_ui_message_expired_message")
                                                           delegate:viewController
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:
                                                  DCUILocalizedString(@"common_ui_generic_delete_all"), DCUILocalizedString(@"common_ui_generic_delete"), nil];
        [alertView setTag:index];
        [alertView show];
    }
}

@end
