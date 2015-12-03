//
//  DKDonkyUI+Localization.h
//  DonkySDK
//
//  Created by Donky Networks on 27/02/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

static inline NSString * DRichMessageLocalizedString(NSString *key) {
    return NSLocalizedStringWithDefaultValue(key, @"DRLocalization", [NSBundle mainBundle], nil, nil);
}


