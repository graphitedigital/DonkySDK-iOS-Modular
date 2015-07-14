//
//  DCUITheme.m
//  RichInbox
//
//  Created by Chris Watson on 05/06/2015.
//  Copyright (c) 2015 Chris Wunsch. All rights reserved.
//

#import "DCUITheme.h"

@interface DCUITheme ()
@property (nonatomic, readwrite) NSString *themeName;
@end

@implementation DCUITheme

- (instancetype)initWithThemeName:(NSString *)themeName {

    self = [super init];

    if (self) {

        self.themeName = themeName;

    }

    return self;

}

- (UIColor *)colourForKey:(NSString *)key {
    return self.themeColours[key];
}

- (UIFont *)fontForKey:(NSString *)key {
    return self.themeFonts[key];
}

- (NSString *)imageForKey:(NSString *)key {
    return self.themeImages[key];
}

@end
