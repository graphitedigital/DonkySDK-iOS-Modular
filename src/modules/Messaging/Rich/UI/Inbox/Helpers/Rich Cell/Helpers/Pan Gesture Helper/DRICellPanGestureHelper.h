//
//  DRICellPanGestureHelper.h
//  RichInbox
//
//  Created by Donky Networks on 11/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol DRICellPanGestureHelperDelegate <NSObject>

- (void)disableScrollView:(BOOL)disable;

- (void)cellWasPanned;

- (void)cellWasOpened:(BOOL)opened;

@end

@interface DRICellPanGestureHelper : UIPanGestureRecognizer <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSLayoutConstraint *contentViewRightConstraint;

@property (nonatomic, strong) NSLayoutConstraint *contentViewLeftConstraint;

@property (nonatomic, weak) id <DRICellPanGestureHelperDelegate> panHelperDelegate;

@property (nonatomic, getter=isEditing) BOOL editing;

- (instancetype)initWithContentView:(UIView *)contentView moreButton:(UIButton *)moreButton topContent:(UIView *)topContent isEditing:(BOOL)editing;

- (void)resetConstraintConstantsToZero;

@end
