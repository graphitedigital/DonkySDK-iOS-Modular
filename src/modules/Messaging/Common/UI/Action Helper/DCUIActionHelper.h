//
//  DCUIActionHelper.h
//  RichInbox
//
//  Created by Donky Networks on 24/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DNMessage.h"

@interface DCUIActionHelper : NSObject

+ (UIViewController *)presentShareActionSheet:(UIViewController *)viewController messageURL:(NSString *)messageURL presentFromPopOver:(BOOL)presentFromPopOver message:(DNMessage *)message;

@end
