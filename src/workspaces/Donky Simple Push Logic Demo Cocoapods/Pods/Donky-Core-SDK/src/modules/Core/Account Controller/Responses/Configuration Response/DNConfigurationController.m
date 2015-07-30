//
//  DNConfigurationController.m
//  Core Container
//
//  Created by Chris Watson on 20/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNConfigurationController.h"
#import "DNUserDefaultsHelper.h"
#import "NSMutableDictionary+DNDictionary.h"

static NSString *const DNConfigurationItems = @"configurationItems";
static NSString *const DNButtonSets = @"ButtonSets";
static NSString *const DNStandardContacts = @"StandardContacts";
static NSString *const DNConfigurationSets = @"configurationSets";
static NSString *const DNConfiguration = @"ConfigurationItems";
static NSString *const DNButtonValues = @"buttonValues";
static NSString *const DNMaximumContentBytes = @"CustomContentMaxSizeBytes";
static NSString *const DNCRichMessageAvailabilityDays = @"RichMessageAvailabilityDays";

@implementation DNConfigurationController

+ (void)saveConfiguration:(NSDictionary *)configuration {
    
    NSDictionary *configItems = configuration[DNConfigurationItems];
    
    NSMutableDictionary *parsedConfig = [[NSMutableDictionary alloc] init];
    //Strip out string tru values:
    [configItems enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isEqualToString:@"true"]) {
            [parsedConfig setObject:@(1) forKey:key];
        }
        else if ([obj isEqualToString:@"false"]) {
            [parsedConfig setObject:@(0) forKey:key];
        }
        else {
            [parsedConfig setObject:obj forKey:key];
        }
    }];

    [DNUserDefaultsHelper saveObject:parsedConfig withKey:DNConfiguration];
    
    NSDictionary *configurationSets = configuration[DNConfigurationSets];
    
    NSDictionary *standardContacts = configurationSets[DNStandardContacts];

    [DNUserDefaultsHelper saveObject:standardContacts withKey:DNStandardContacts];

    NSDictionary *buttonSets = configurationSets[DNButtonSets];

    [DNUserDefaultsHelper saveObject:buttonSets withKey:DNButtonSets];

}

+ (NSDictionary *)buttonSets {
    return [DNUserDefaultsHelper objectForKey:DNButtonSets];
}

+ (NSDictionary *)standardContacts {
    return [DNUserDefaultsHelper objectForKey:DNStandardContacts];
}

+ (NSDictionary *)configuration {
    return [DNUserDefaultsHelper objectForKey:DNConfiguration];
}

+ (NSMutableSet *)buttonsAsSets {

    NSArray *buttons = [DNConfigurationController buttonSets][@"buttonSets"];
    NSMutableSet *buttonSets = [[NSMutableSet alloc] init];
    NSArray *buttonCombinations = @[@"|F|F", @"|F|B", @"|B|F", @"|B|B"];

    [buttonCombinations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *buttonCombination = obj;
        [buttons enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx2, BOOL *stop2) {
            NSDictionary *buttonDict = obj2;
            NSArray *buttonValues = buttonDict[DNButtonValues];
            [buttonSets addObject:[DNConfigurationController categoryWithFirstButtonTitle:[buttonValues firstObject]
                                                                              firstButtonIdentifier:[buttonValues firstObject]
                                                                             firstButtonIsForground:idx != 2 && idx != 3
                                                                                  secondButtonTitle:[buttonValues lastObject]
                                                                             secondButtonIdentifier:[buttonValues lastObject]
                                                                           secondButtonIsForeground:idx != 1 && idx != 3
                                                                              andCategoryIdentifier:[buttonDict[@"buttonSetId"] stringByAppendingString:buttonCombination]]];
        }];
    }];

    return buttonSets;

}

+ (UIMutableUserNotificationCategory *)categoryWithFirstButtonTitle:(NSString *)firstButtonTitle firstButtonIdentifier:(NSString *)firstButtonIdentifier firstButtonIsForground:(BOOL)firstButtonForeground secondButtonTitle:(NSString *)secondButtonTitle secondButtonIdentifier:(NSString *)secondButtonIdentifier secondButtonIsForeground:(BOOL)secondButtonForeground andCategoryIdentifier:(NSString *)categoryIdentifier {

    UIMutableUserNotificationAction *firstAction = [[UIMutableUserNotificationAction alloc] init];
    firstAction.title = firstButtonTitle;
    firstAction.identifier = firstButtonIdentifier;
    firstAction.activationMode = firstButtonForeground ? UIUserNotificationActivationModeForeground : UIUserNotificationActivationModeBackground;
    firstAction.destructive = NO;
    firstAction.authenticationRequired = NO;

    UIMutableUserNotificationAction *secondAction = [[UIMutableUserNotificationAction alloc] init];
    secondAction.title = secondButtonTitle;
    secondAction.identifier = secondButtonIdentifier;
    secondAction.activationMode = secondButtonForeground ? UIUserNotificationActivationModeForeground : UIUserNotificationActivationModeBackground;
    secondAction.destructive = NO;
    secondAction.authenticationRequired = NO;

    UIMutableUserNotificationCategory *notificationCategory = [[UIMutableUserNotificationCategory alloc] init];
    notificationCategory.identifier = categoryIdentifier;
    [notificationCategory setActions:@[secondAction, firstAction] forContext:UIUserNotificationActionContextDefault];
    [notificationCategory setActions:@[secondAction, firstAction] forContext:UIUserNotificationActionContextMinimal];

    return notificationCategory;

}

+ (id)objectFromConfiguration:(NSString *)string {
    return [DNConfigurationController configuration][string];
}

+ (void)saveConfigurationObject:(id)object forKey:(NSString *)key {
    NSMutableDictionary *configItems = [[DNConfigurationController configuration] mutableCopy];
    [configItems dnSetObject:object forKey:key];
    [DNUserDefaultsHelper saveObject:configItems withKey:DNConfiguration];
}

+ (CGFloat)maximumContentByteSize {
    return [[DNConfigurationController objectFromConfiguration:DNMaximumContentBytes] floatValue];
}

+ (NSInteger)richMessageAvailabilityDays {
    return [[DNConfigurationController objectFromConfiguration:DNCRichMessageAvailabilityDays] integerValue];
}

@end
