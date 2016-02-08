//
//  DRICellPanGestureHelper.m
//  RichInbox
//
//  Created by Donky Networks on 11/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DRICellPanGestureHelper.h"
#import "UIView+AutoLayout.h"

@interface DRICellPanGestureHelper ()
@property (nonatomic) CGPoint panStartPoint;
@property (nonatomic) CGFloat startingRightLayoutConstraintConstant;
@property(nonatomic, strong) UIView *contentView;
@property(nonatomic, strong) UIButton *moreButton;
@property(nonatomic, strong) UIView *topContentView;
@end

@implementation DRICellPanGestureHelper

- (instancetype)initWithContentView:(UIView *)contentView moreButton:(UIButton *)moreButton topContent:(UIView *)topContent isEditing:(BOOL)editing {

    self = [super initWithTarget:self action:@selector(panThisCell:)];
    
    if (self) {

        [self setContentView:contentView];

        [self setMoreButton:moreButton];

        [self setTopContentView:topContent];

        [self setEditing:editing];


        [self setDelegate:self];

        [[self topContentView] addGestureRecognizer:self];
        
    }

    return self;
}

- (void)panThisCell:(UIPanGestureRecognizer *)recognizer
{
    if ([self isEditing]) {
        return;
    }

    switch ([recognizer state]) {
        case UIGestureRecognizerStateBegan:
            [self setPanStartPoint:[recognizer translationInView:[self topContentView]]];
            [self setStartingRightLayoutConstraintConstant:[[self contentViewRightConstraint] constant]];
            break;

        case UIGestureRecognizerStateChanged: {

            if ([[self panHelperDelegate] respondsToSelector:@selector(disableScrollView:)]) {
                [[self panHelperDelegate] disableScrollView:YES];
            }

            CGPoint currentPoint = [recognizer translationInView:[self topContentView]];
            CGFloat deltaX = currentPoint.x - [self panStartPoint].x;

            BOOL panningLeft = NO;

            if (currentPoint.x > -10 && currentPoint.x < 10) {
                return;
            }

            if (currentPoint.x < [self panStartPoint].x) {
                panningLeft = YES;
            }

            [self.moreButton setHidden:NO];

            if (self.startingRightLayoutConstraintConstant == 0) {
                //The cell was closed and is now opening
                if (!panningLeft) {
                    CGFloat constant = MAX(deltaX, 0);
                    if (constant < 75) {
                        [[self contentViewRightConstraint] setConstant:constant];
                    }
                } else {
                    CGFloat constant = MIN(deltaX, [[self moreButton] frame].size.width);
                    if (constant == [[self moreButton] frame].size.width) {
                        [self setConstraintsToShowAllButtons];
                    } else {
                        [[self contentViewRightConstraint] setConstant:constant];
                    }
                }
            }else {
                //The cell was at least partially open.
                CGFloat adjustment = [self startingRightLayoutConstraintConstant] + deltaX;
                if (!panningLeft) {
                    CGFloat constant = MAX(adjustment, 0);
                    if (constant < 0) {
                        [[self contentViewRightConstraint] setConstant:constant];
                    }
                } else {
                    CGFloat constant = MIN(adjustment, [[self moreButton] frame].size.width);
                    if (constant == [[self moreButton] frame].size.width) {
                        [self setConstraintsToShowAllButtons];
                    } else {
                        [[self contentViewRightConstraint] setConstant:constant];
                    }
                }
            }
            [[self contentViewLeftConstraint] setConstant:[[self contentViewRightConstraint] constant]];
        }
            break;

        case UIGestureRecognizerStateEnded:
            if ([self startingRightLayoutConstraintConstant] == 0) {
                //We were opening
                CGFloat halfOfButtonOne = CGRectGetWidth([[self moreButton] frame]) * -1;
                if ([[self contentViewRightConstraint] constant] < halfOfButtonOne) {
                    //Open all the way
                    [self setConstraintsToShowAllButtons];
                } else {
                    //Re-close
                    [self resetConstraintConstantsToZero];
                }

            } else {
                CGFloat buttonOnePlusHalfOfButton2 = CGRectGetWidth([[self moreButton] frame]) / 2;
                if ([[self contentViewRightConstraint] constant] >= buttonOnePlusHalfOfButton2) {
                    [self setConstraintsToShowAllButtons];
                } else {
                    [self resetConstraintConstantsToZero];
                }
            }
            break;

        case UIGestureRecognizerStateCancelled:
            if ([self startingRightLayoutConstraintConstant] == 0) {
                [self resetConstraintConstantsToZero];
            } else {
                [self setConstraintsToShowAllButtons];
            }
            break;

        default:
            break;
    }

    if ([[self panHelperDelegate] respondsToSelector:@selector(cellWasPanned)]) {
        [[self panHelperDelegate] cellWasPanned];
    }
}

- (void)resetConstraintConstantsToZero {
    if ([self contentViewLeftConstraint] && [self contentViewRightConstraint]) {
        [[self contentView] layoutIfNeeded];
        [UIView animateWithDuration:0.25 animations:^{
            [[self contentView] removeConstraints:@[[self contentViewLeftConstraint], [self contentViewRightConstraint]]];
            [self setContentViewRightConstraint:[[self topContentView] pinAttribute:NSLayoutAttributeRight toSameAttributeOfItem:[self contentView]]];
            [self setContentViewLeftConstraint:[[self topContentView] pinAttribute:NSLayoutAttributeLeft toSameAttributeOfItem:[self contentView]]];
            [[self contentView] layoutIfNeeded];
            [self setStartingRightLayoutConstraintConstant:[[self contentViewRightConstraint] constant]];
        } completion:^(BOOL completion) {
            [[self moreButton] setHidden:YES];
            if ([[self panHelperDelegate] respondsToSelector:@selector(disableScrollView:)]) {
                [[self panHelperDelegate] disableScrollView:NO];
            }

            if ([[self panHelperDelegate] respondsToSelector:@selector(cellWasOpened:)]) {
                [[self panHelperDelegate] cellWasOpened:NO];
            }
        }];
    }
}

- (void)setConstraintsToShowAllButtons {
    [[self contentView] layoutIfNeeded];
    [UIView animateWithDuration:0.25 animations:^{
        [[self contentView] removeConstraints:@[[self contentViewLeftConstraint], [self contentViewRightConstraint]]];
        [self setContentViewRightConstraint:[[self topContentView] pinAttribute:NSLayoutAttributeRight  toSameAttributeOfItem:[self contentView] withConstant:-[[self moreButton] frame].size.width]];
        [self setContentViewLeftConstraint:[[self topContentView] pinAttribute:NSLayoutAttributeLeft toSameAttributeOfItem:[self contentView] withConstant:-[[self moreButton] frame].size.width]];
        [[self contentView] layoutIfNeeded];
        [self setStartingRightLayoutConstraintConstant:[[self contentViewRightConstraint] constant]];
    } completion:^(BOOL completion) {
        if ([[self panHelperDelegate] respondsToSelector:@selector(disableScrollView:)]) {
            [[self panHelperDelegate] disableScrollView:NO];
        }

        if ([[self panHelperDelegate] respondsToSelector:@selector(cellWasOpened:)]) {
            [[self panHelperDelegate] cellWasOpened:YES];
        }
    }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)panGestureRecognizer {

    if (![self isEditing]) {
        CGPoint velocity = [self velocityInView:[self topContentView]];
        return fabs(velocity.x) > fabs(velocity.y);
    }

    return NO;
}
@end
