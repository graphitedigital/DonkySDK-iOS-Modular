//
//  DNContentNotification.m
//  Core Container
//
//  Created by Donky Networks on 19/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNContentNotification.h"
#import "NSMutableDictionary+DNDictionary.h"

@interface DNContentNotification ()
@property(nonatomic, readwrite) NSDictionary *audience;
@property(nonatomic, readwrite) NSArray *filters;
@property(nonatomic, readwrite) NSDictionary *content;
@property(nonatomic, readwrite) NSDictionary *nativePush;
@end

@implementation DNContentNotification

- (instancetype)initWithUsers:(NSArray *)users customType:(NSString *)customType data:(id)data {
    self = [super init];

    if (self) {

        NSMutableDictionary *constructedAudience = [[NSMutableDictionary alloc] init];
        [constructedAudience dnSetObject:@"specifiedUsers" forKey:@"type"];
        
        NSMutableArray *usersArray = [[NSMutableArray alloc] init];
        
        [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [usersArray addObject:@{@"userId" : obj}];
        }];
        
        [constructedAudience dnSetObject:usersArray forKey:@"users"];
        [self setAudience:constructedAudience];
        
        
        NSMutableDictionary *content = [[NSMutableDictionary alloc] init];
        [content dnSetObject:@"Custom" forKey:@"type"];
        [content dnSetObject:customType forKey:@"customType"];
        [content dnSetObject:data forKey:@"data"];
        [self setContent:content];
    }

    return self;
}

- (instancetype)initWithAudience:(NSDictionary *)audience filters:(NSArray *)filters content:(NSDictionary *)content nativePush:(NSDictionary *)nativePush {

    self = [super init];

    if (self) {

        [self setAudience:audience];
        [self setFilters:filters];
        [self setNativePush:nativePush];
        [self setContent:content];
                
    }

    return self;
}

@end
