//
//  DKDonkyUI+Localization.h
//  DonkySDK
//
//  Created by Donky Networks on 14/04/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "DCUIMainController.h"

static inline NSString *DCUILocalizedString(NSString *key) {
    return NSLocalizedStringWithDefaultValue(key, @"DCUILocalization", [NSBundle bundleForClass:[DCUIMainController class]], nil, comment);
}

