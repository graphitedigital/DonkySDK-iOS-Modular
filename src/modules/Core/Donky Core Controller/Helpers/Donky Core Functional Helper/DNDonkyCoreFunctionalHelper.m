//
//  DNDonkyCoreFunctionalHelper.m
//  DonkyCore
//
//  Created by Donky Networks on 28/04/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DNDonkyCoreFunctionalHelper.h"
#import "DNServerNotification.h"
#import "DNSystemHelpers.h"
#import "DNNetwork+Localization.h"
#import "UIViewController+DNRootViewController.h"
#import "DNLoggingController.h"

@implementation DNDonkyCoreFunctionalHelper

+ (void)handleNewDeviceMessage:(DNServerNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *model = [notification data][@"model"];
        NSString *operatingSystem = [notification data][@"operatingSystem"];

        if ([DNSystemHelpers systemVersionAtLeast:8.0]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:DNNetworkLocalizedString(@"dn_donky_core_new_device_title")
                                                                                     message:[NSString stringWithFormat:DNNetworkLocalizedString(@"dn_donky_core_new_device_message"), model, operatingSystem]
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:DNNetworkLocalizedString(@"dn_donky_core_new_device_button") style:UIAlertActionStyleDefault handler:nil]];
            UIViewController *rootView = [UIViewController applicationRootViewController];
            if (!rootView)
                DNErrorLog(@"Couldn't present alert view, root view is nil.");
            else
                [rootView presentViewController:alertController animated:YES completion:nil];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:DNNetworkLocalizedString(@"dn_donky_core_new_device_tile")
                                                                message:[NSString stringWithFormat:DNNetworkLocalizedString(@"dn_donky_core_new_device_message"), model, operatingSystem]
                                                               delegate:nil
                                                      cancelButtonTitle:DNNetworkLocalizedString(@"dn_donky_core_new_device_button")
                                                      otherButtonTitles:nil];
            [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        }
    });
}


@end
