//
//  DNConfigurationController.m
//  Core Container
//
//  Created by Donky Networks on 20/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

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
static NSString *const DNMaximumSignalRBytes = @"SignalRMaxMessageSizeBytes";

@implementation DNConfigurationController

+ (void)saveConfiguration:(NSDictionary *)configuration {
    
    NSDictionary *configItems = configuration[DNConfigurationItems];
    
    NSMutableDictionary *parsedConfig = [[NSMutableDictionary alloc] init];
    //Strip out string tru values:
    [configItems enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isEqualToString:@"true"]) {
            parsedConfig[key] = @(1);
        }
        else if ([obj isEqualToString:@"false"]) {
            parsedConfig[key] = @(0);
        }
        else {
            parsedConfig[key] = obj;
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
    [firstAction setTitle:firstButtonTitle];
    [firstAction setIdentifier:firstButtonIdentifier];
    [firstAction setActivationMode:firstButtonForeground ? UIUserNotificationActivationModeForeground : UIUserNotificationActivationModeBackground];
    [firstAction setDestructive:NO];
    [firstAction setAuthenticationRequired:NO];

    UIMutableUserNotificationAction *secondAction = [[UIMutableUserNotificationAction alloc] init];
    [secondAction setTitle:secondButtonTitle];
    [secondAction setIdentifier:secondButtonIdentifier];
    [secondAction setActivationMode:secondButtonForeground ? UIUserNotificationActivationModeForeground : UIUserNotificationActivationModeBackground];
    [secondAction setDestructive:NO];
    [secondAction setAuthenticationRequired:NO];

    UIMutableUserNotificationCategory *notificationCategory = [[UIMutableUserNotificationCategory alloc] init];
    [notificationCategory setIdentifier:categoryIdentifier];
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

+ (CGFloat)maximumSignalRByteSize {
    return [[DNConfigurationController objectFromConfiguration:DNMaximumSignalRBytes] floatValue];
}

+ (NSInteger)richMessageAvailabilityDays {
    return [[DNConfigurationController objectFromConfiguration:DNCRichMessageAvailabilityDays] integerValue];
}

@end
