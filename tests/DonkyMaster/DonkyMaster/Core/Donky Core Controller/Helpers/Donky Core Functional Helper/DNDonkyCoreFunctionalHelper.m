//
//  DNDonkyCoreFunctionalHelper.m
//  DonkyCore
//
//  Created by Chris Watson on 28/04/2015.
//  Copyright (c) 2015 Chris Watson. All rights reserved.
//

#import "DNDonkyCoreFunctionalHelper.h"
#import "DNServerNotification.h"
#import "DNSystemHelpers.h"
#import "DNNetwork+Localization.h"
#import "UIViewController+DNRootViewController.h"
#import "DNLoggingController.h"

@implementation DNDonkyCoreFunctionalHelper


+ (void)handleNewDeviceMessage:(DNServerNotification *)notification {


    NSString *model = [notification data][@"model"];
    NSString *operatingSystem = [notification data][@"operatingSystem"];

    if ([DNSystemHelpers donkySystemVersionAtLeast:8.0]) {
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

}


@end
