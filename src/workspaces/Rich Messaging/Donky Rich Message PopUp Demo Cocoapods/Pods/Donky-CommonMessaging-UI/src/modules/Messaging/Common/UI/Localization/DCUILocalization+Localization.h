//
//  DKDonkyUI+Localization.h
//  DonkySDK
//
//  Created by David Taylor on 14/04/2014.
//  Copyright (c) 2014 Compsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

static inline NSString *DCUILocalizedString(NSString *key) {
    return NSLocalizedStringWithDefaultValue(key, @"DCUILocalization", [NSBundle mainBundle], nil, comment);
}

