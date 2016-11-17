//
//  DKDonkyUI+Localization.m
//  DonkySDK
//
//  Created by Donky Networks on 27/02/2015.
//  Copyright (c) 2015 Dynmark International Ltd. All rights reserved.
//

#import "DRichMessage+Localization.h"
#import "DCUIMainController.h"

NSString *DRichMessageLocalizedString(NSString *key) {
  NSBundle *bundle = [NSBundle bundleForClass:[DCUIMainController class]];
  return NSLocalizedStringWithDefaultValue(key, @"DRLocalization", bundle, nil, nil);
}
