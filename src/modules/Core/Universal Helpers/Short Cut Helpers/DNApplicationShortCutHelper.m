//
//  DNApplicationShortCutHelper.m
//  ChatUI
//
//  Created by Donky Networks on 03/10/2015.
//  Copyright © 2015 Donky Networks. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DNApplicationShortCutHelper.h"
#import "UIViewController+DNRootViewController.h"
#import "DNLoggingController.h"

@implementation DNApplicationShortCutHelper

+ (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    NSString *type = [shortcutItem type];
    if ([type isEqualToString:@"DonkyNewChatMessage"]) {
        //Start new message:
        SEL newChatSelector = NSSelectorFromString(@"newShortCutConversation");
        id serviceInstance = NSClassFromString(@"DChatUIMainController");
        if ([serviceInstance respondsToSelector:newChatSelector]) {
            UINavigationController *newMessage = ((UINavigationController* (*)(id, SEL))[serviceInstance methodForSelector:newChatSelector])(serviceInstance, newChatSelector);
            if (newMessage) {
                [[UIViewController applicationRootViewController] presentViewController:newMessage animated:YES completion:nil];
            }
        }
        else {
            DNErrorLog(@"Couldn't load a new chat converastion, DCChatUIMainController class could not be found. Please ensure you have included the Donky-ChatMessage-Inbox module");
        }
    }
}

@end
