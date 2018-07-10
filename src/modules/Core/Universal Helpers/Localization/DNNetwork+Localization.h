//
//  DKDonkyUI+Localization.h
//  DonkySDK
//
//  Created by Donky Networks on 27/02/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "DNDonkyCore.h"

static inline NSString * DNNetworkLocalizedString(NSString *key) {
    return NSLocalizedStringWithDefaultValue(key, @"DNLocalization", [NSBundle bundleForClass:[DNDonkyCore class]], nil, nil);
}


