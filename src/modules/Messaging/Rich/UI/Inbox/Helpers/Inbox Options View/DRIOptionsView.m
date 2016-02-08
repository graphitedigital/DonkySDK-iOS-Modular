//
//  DRIOptionsView.m
//  RichInbox
//
//  Created by Donky Networks on 07/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "UIView+AutoLayout.h"
#import "DRIOptionsView.h"
#import "DCUILocalization+Localization.h"
#import "DRUITheme.h"
#import "DRUIThemeConstants.h"
#import "DCUIThemeController.h"

@interface DRIOptionsView ()
@property(nonatomic, strong) UIButton *deleteButton;
@end

@implementation DRIOptionsView

- (instancetype)init {

    self = [super init];

    if (self) {

        DRUITheme *theme = (DRUITheme *) [[DCUIThemeController sharedInstance] themeForName:kDRUIThemeName];

        //We don't have a theme, so initialise with the default:
        if (!theme) {
            theme = [[DRUITheme alloc] initWithDefaultTheme];
        }

        [self setBackgroundColor:[theme colourForKey:kDRUIInboxOptionsBackgroundColour]];

        [self setDeleteButton:[UIButton buttonWithType:UIButtonTypeCustom]];
        [[self deleteButton] setTranslatesAutoresizingMaskIntoConstraints:NO];
        [[self deleteButton] setTitleColor:[theme colourForKey:kDRUIInboxOptionsEnabledTextColour] forState:UIControlStateNormal];
        [[self deleteButton] setTitleColor:[theme colourForKey:kDRUIInboxOptionsDisabledTextColour] forState:UIControlStateDisabled];
        [[[self deleteButton] titleLabel] setTextAlignment:NSTextAlignmentCenter];
        [[[self deleteButton] layer] setBorderWidth:0.75];
        [[[self deleteButton] layer] setBorderColor:[theme colourForKey:kDRUIInboxOptionsDividerColour].CGColor];
        [[[self deleteButton] titleLabel] setFont:[theme fontForKey:kDRUIInboxOptionsViewFont]];
        [[self deleteButton] addTarget:self action:@selector(deleteTapped:) forControlEvents:UIControlEventTouchUpInside];
        [[self deleteButton] setTitle:DCUILocalizedString(@"common_ui_generic_delete") forState:UIControlStateNormal];
        [[self deleteButton] setEnabled:NO];
        [self addSubview:[self deleteButton]];

        [[self deleteButton] pinToSuperviewEdges:JRTViewPinAllEdges inset:0.0];

    }

    return self;

}

- (void)updateDelete:(BOOL)enabled {
    [[self deleteButton] setEnabled:enabled];
}

- (void)deleteTapped:(id)sender {
    if ([[self delegate] respondsToSelector:@selector(deleteButtonTapped)]) {
        [[self delegate] deleteButtonTapped];
    }
}

@end
