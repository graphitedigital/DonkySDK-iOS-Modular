//
//  DKDonkyUI+Localization.h
//  DonkySDK
//
//  Created by Donky Networks on 14/04/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

static inline NSString *DCUILocalizedString(NSString *key) {
    return NSLocalizedStringWithDefaultValue(key, @"DCUILocalization", [NSBundle mainBundle], nil, comment);
}

