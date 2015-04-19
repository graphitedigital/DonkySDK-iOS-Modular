//
//  DCUIRMessageViewController.h
//  RichPopUp
//
//  Created by Chris Watson on 13/04/2015.
//  Copyright (c) 2015 Chris Watson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DNRichMessage;

@protocol DCUIRMessageViewControllerDelegate <NSObject>

- (void)messageWasClosed:(NSString *)messageID;

@end

@interface DCUIRMessageViewController : UIViewController <UIPopoverControllerDelegate>

@property (nonatomic, weak) id <DCUIRMessageViewControllerDelegate> delegate;

- (instancetype)initWithRichMessage:(DNRichMessage *)richMessage;

- (UINavigationController *)richPopUpNavigationControllerWithModalPresentationStyle:(UIModalPresentationStyle)presentationStyle;

@end
