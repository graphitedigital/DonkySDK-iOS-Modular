//
//  DCUITheme.m
//  RichInbox
//
//  Created by Donky Networks on 05/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

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

- (UIImage *)imageForKey:(NSString *)key {
    return self.themeImages[key];
}

@end
