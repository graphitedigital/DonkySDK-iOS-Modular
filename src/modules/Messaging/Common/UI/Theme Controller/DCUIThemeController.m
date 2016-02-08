//
//  DCUIThemeController.m
//  RichInbox
//
//  Created by Donky Networks on 03/06/2015.
//  Copyright (c) 2015 Donky Networks. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DCUIThemeController.h"
#import "NSMutableDictionary+DNDictionary.h"

@interface DCUIThemeController ()
@property(nonatomic, strong) NSMutableDictionary *themes;
@end

@implementation DCUIThemeController

+(DCUIThemeController *)sharedInstance
{
    static dispatch_once_t pred;
    static DCUIThemeController *sharedInstance = nil;

    dispatch_once(&pred, ^{
        sharedInstance = [[DCUIThemeController alloc] initPrivate];
    });

    return sharedInstance;
}

-(instancetype)init {
    return [DCUIThemeController sharedInstance];
}

-(instancetype)initPrivate
{

    self  = [super init];

    if (self) {

        [self setThemes:[[NSMutableDictionary alloc] init]];
        
    }

    return self;
}

- (void)addTheme:(DCUITheme *)theme {
    [[self themes] dnSetObject:theme forKey:[theme themeName]];
}

- (DCUITheme *)themeForName:(NSString *)themeName {
    return [self themes][themeName];
}

@end
