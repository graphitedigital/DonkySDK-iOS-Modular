//
//  DRUITheme.m
//  RichInbox
//
//  Created by Chris Watson on 05/06/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import "DRUITheme.h"
#import "NSMutableDictionary+DNDictionary.h"
#import "DCUIConstants.h"
#import "DRUIThemeConstants.h"

@implementation DRUITheme

- (instancetype) init {

    self = [super initWithThemeName:kDRUIThemeName];

    if (self) {


    }

    return self;
}

- (instancetype)initWithDefaultTheme {

    self = [self initWithThemeName:kDRUIThemeName];

    if (self) {

        [self setThemeColours:[[NSMutableDictionary alloc] init]];

        //Navigation Bar:
        [[self themeColours] dnSetObject:[UIColor colorWithRed:101 / 255.0f green:47 / 255.0f blue:142 / 255.0f alpha:1.0] forKey:kDCUIThemeDonkyPurpleColour];

        //No messages view
        [[self themeColours] dnSetObject:[UIColor colorWithRed:255 / 255.0f green:255 / 255.0f blue:255 / 255.0f alpha:0.0] forKey:kDRUIInboxNoMessagesBackgroundColour];
        [[self themeColours] dnSetObject:[UIColor colorWithRed:0 / 255.0f green:0 / 255.0f blue:0 / 255.0f alpha:1.0] forKey:kDRUIInboxNoMessagesTextColour];

        //Cell
        [[self themeColours] dnSetObject:[UIColor colorWithRed:255 / 255.0f green:255 / 255.0f blue:255 / 255.0f alpha:1.0] forKey:kDRUIInboxCellBackgroundColour];
        [[self themeColours] dnSetObject:[UIColor colorWithRed:199 / 255.0f green:199 / 255.0f blue:204 / 255.0f alpha:1.0] forKey:kDRUInboxCellSelectedColour];

        //More button:
        [[self themeColours] dnSetObject:[UIColor colorWithRed:199 / 255.0f green:199 / 255.0f blue:204 / 255.0f alpha:1.0] forKey:kDRUIInboxCellMoreButtonColour];

        //Title Label:
        [[self themeColours] dnSetObject:[UIColor colorWithRed:0 / 255.0f green:0 / 255.0f blue:0 / 255.0f alpha:1.0] forKey:kDRUIInboxUnreadTitleColour];
        [[self themeColours] dnSetObject:[UIColor colorWithRed:0 / 255.0f green:0 / 255.0f blue:0 / 255.0f alpha:1.0] forKey:kDRUIInboxReadTitleColour];

        //Description label:
        [[self themeColours] dnSetObject:[UIColor colorWithRed:0 / 255.0f green:0 / 255.0f blue:0 / 255.0f alpha:1.0] forKey:kDRUIInboxUnreadDescriptionColour];
        [[self themeColours] dnSetObject:[UIColor colorWithRed:0 / 255.0f green:0 / 255.0f blue:0 / 255.0f alpha:1.0] forKey:kDRUIInboxReadDescriptionColour];

        //Date label:
        [[self themeColours] dnSetObject:[UIColor colorWithRed:38 / 255.0f green:167 / 255.0f blue:223 / 255.0f alpha:1.0] forKey:kDRUIInboxUnreadDateColour];
        [[self themeColours] dnSetObject:[UIColor colorWithRed:138 / 255.0f green:138 / 255.0f blue:139 / 255.0f alpha:1.0] forKey:kDRUIInboxReadDateColour];

        //Options view:
        [[self themeColours] dnSetObject:[UIColor colorWithRed:38 / 255.0f green:167 / 255.0f blue:223 / 255.0f alpha:1.0] forKey:kDRUIInboxOptionsEnabledTextColour];
        [[self themeColours] dnSetObject:[UIColor colorWithRed:0 / 255.0f green:0 / 255.0f blue:0 / 255.0f alpha:1.0] forKey:kDRUIInboxOptionsDisabledTextColour];
        [[self themeColours] dnSetObject:[UIColor colorWithRed:255 / 255.0f green:255 / 255.0f blue:255 / 255.0f alpha:1.0]  forKey:kDRUIInboxOptionsBackgroundColour];
        [[self themeColours] dnSetObject:[UIColor colorWithRed:138 / 255.0f green:138 / 255.0f blue:139 / 255.0f alpha:1.0] forKey:kDRUIInboxOptionsDividerColour];

        //New Banner:
        [[self themeColours] dnSetObject:[UIColor colorWithRed:38 / 255.0f green:167 / 255.0f blue:223 / 255.0f alpha:1.0] forKey:kDRUIInboxNewBannerColour];
        [[self themeColours] dnSetObject:[UIColor colorWithRed:255 / 255.0f green:255 / 255.0f blue:255 / 255.0f alpha:1.0] forKey:kDRUInboxNewBannerTextColour];

        //Avatar border colour:
        [[self themeColours] dnSetObject:[UIColor colorWithRed:138 / 255.0f green:138 / 255.0f blue:139 / 255.0f alpha:0.75] forKey:kDRUInboxCellAvatarBorderColour];

        //Refresh control tint colour:
        [[self themeColours] dnSetObject:[UIColor colorWithRed:38 / 255.0f green:167 / 255.0f blue:223 / 255.0f alpha:1.0] forKey:kDRUIInboxRefreshControlTintColour];

        ////FONTS////
        [self setThemeFonts:[[NSMutableDictionary alloc] init]];

        //Title Label"
        [[self themeFonts] dnSetObject:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] forKey:kDRUIInboxCellTitleFont];

        //Description Label:
        [[self themeFonts] dnSetObject:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] forKey:kDRUIInboxCellDescriptionFont];

        //Date Label:
        [[self themeFonts] dnSetObject:[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote] forKey:kDRUIInboxCellDateFont];

        //Options view:
        [[self themeFonts] dnSetObject:[UIFont preferredFontForTextStyle:UIFontTextStyleBody] forKey:kDRUIInboxOptionsViewFont];

        //No messages view
        [[self themeFonts] dnSetObject:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] forKey:kDRUIInboxNoMessagesFont];

        //New banner:
        [[self themeFonts] dnSetObject:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] forKey:kDRUIInboxNewBannerFont];

    }

    return self;
}

@end
