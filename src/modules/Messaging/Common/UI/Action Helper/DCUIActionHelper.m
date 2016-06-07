//
//  DCUIActionHelper.m
//  RichInbox
//
//  Created by Donky Networks on 24/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DCMMainController.h"
#import "DCUILocalization+Localization.h"
#import "DNSystemHelpers.h"
#import "DCUIActionHelper.h"

@implementation DCUIActionHelper

+ (UIViewController *)presentShareActionSheet:(UIViewController *)viewController messageURL:(NSString *)messageURL presentFromPopOver:(BOOL)presentFromPopOver message:(DNMessage *)message {
    NSString *url = [NSString stringWithFormat:DCUILocalizedString(@"share_url_message"), messageURL];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
    
    if ([DNSystemHelpers systemVersionAtLeast:8.0]) {
        [controller setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
            [DCMMainController reportSharingOfRichMessage:message sharedUsing:activityType];
        }];
    }
    else {
        [controller setCompletionHandler:^(NSString *activityType, BOOL completed) {
            //Report sharing:
            [DCMMainController reportSharingOfRichMessage:message sharedUsing:activityType];
        }];
    }

    if ([DNSystemHelpers isDeviceIPad] && presentFromPopOver) {
        return controller;
    }
    else {
        [viewController.navigationController presentViewController:controller animated:YES completion:nil];
    };

    return nil;
}

@end
