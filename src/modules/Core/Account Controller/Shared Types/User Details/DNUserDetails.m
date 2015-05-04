//
//  DNUserDetails.m
//  Core Container
//
//  Created by Chris Watson on 17/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#import "DNUserDetails.h"
#import "DNDeviceUser.h"
#import "NSMutableDictionary+DNDictionary.h"
#import "DNLoggingController.h"
#import "DNTag.h"

static NSString *const DNUserRegistrationDisplayName = @"displayName";
static NSString *const DNUserRegistrationEmailAddress = @"emailAddress";
static NSString *const DNUserRegistrationCountryCode = @"countryCode";
static NSString *const DNUserRegistrationMobileNumber = @"mobileNumber";
static NSString *const DNLastName = @"lastName";
static NSString *const DNFirstName = @"firstName";
static NSString *const DNUserRegistrationAssetId = @"avatarAssetId";
static NSString *const DNUserRegistrationAdditionalProperties = @"additionalProperties";
static NSString *const DNRegistrationId = @"id";

@interface DNUserDetails ()

@property(nonatomic, readwrite) NSString *userID;
@property(nonatomic, readwrite, getter=isAnonymous) BOOL anonymous;
@property(nonatomic, readwrite) NSString *displayName;
@property(nonatomic, readwrite) NSString *emailAddress;
@property(nonatomic, readwrite) NSString *mobileNumber;
@property(nonatomic, readwrite) NSString * countryCode;
@property(nonatomic, readwrite) NSString * avatarAssetID;
@property(nonatomic, readwrite) NSMutableArray *selectedTags;
@property(nonatomic, readwrite) NSDictionary *additionalProperties;
@property(nonatomic, readwrite) NSString *firstName;
@property(nonatomic, readwrite) NSString *lastName;
@end

@implementation DNUserDetails

- (instancetype) init {

    self = [super init];

    if (self) {
        [self setAnonymous:YES];
    }

    return self;
}

- (instancetype)initWithDeviceUser:(DNDeviceUser *)deviceUser {

    self = [super init];

    if (self) {

        [self setUserID:[deviceUser userID]];
        [self setAnonymous:[[deviceUser isAnonymous] boolValue]];
        [self setDisplayName:[deviceUser displayName]];
        [self setEmailAddress:[deviceUser emailAddress]];
        [self setMobileNumber:[deviceUser mobileNumber]];
        [self setCountryCode:[deviceUser countryCode]];
        [self setFirstName:[deviceUser firstName]];
        [self setLastName:[deviceUser lastName]];
        [self setAvatarAssetID:[deviceUser avatarAssetID]];
        [self setSelectedTags:[deviceUser selectedTags]];
        [self setAdditionalProperties:[deviceUser additionalProperties]];

    }

    return self;
}

- (instancetype)initWithUserID:(NSString *)userID displayName:(NSString *)displayName emailAddress:(NSString *)emailAddress mobileNumber:(NSString *)mobileNumber countryCode:(NSString *)countryCode firstName:(NSString *)firstName lastName:(NSString *)lastName avatarID:(NSString *)avatarID selectedTags:(NSMutableArray *)selectedTags additionalProperties:(NSDictionary *)additionalProperties anonymous:(BOOL) isAnonymous {

    self = [super init];

    if (self) {
        [self setUserID:userID];
        [self setDisplayName:displayName];
        [self setEmailAddress:emailAddress];
        [self setCountryCode:countryCode];
        [self setMobileNumber:mobileNumber];
        [self setFirstName:firstName];
        [self setLastName:lastName];
        [self setAvatarAssetID:avatarID];
        [self setSelectedTags:selectedTags];
        [self setAdditionalProperties:additionalProperties];
        [self setAnonymous:isAnonymous];
    }

    return self;
}

- (instancetype)initWithUserID:(NSString *)userID displayName:(NSString *)displayName emailAddress:(NSString *)emailAddress mobileNumber:(NSString *)mobileNumber countryCode:(NSString *)countryCode firstName:(NSString *)firstName lastName:(NSString *)lastName avatarID:(NSString *)avatarID selectedTags:(NSMutableArray *)selectedTags additionalProperties:(NSDictionary *)additionalProperties {
    
    self = [super init];

    if (self) {
        [self setUserID:userID];
        [self setDisplayName:displayName];
        [self setEmailAddress:emailAddress];
        [self setCountryCode:countryCode];
        [self setMobileNumber:mobileNumber];
        [self setFirstName:firstName];
        [self setLastName:lastName];
        [self setAvatarAssetID:avatarID];
        [self setSelectedTags:selectedTags];
        [self setAdditionalProperties:additionalProperties];
        [self setAnonymous:displayName == nil]; //We set to anonymous if there is no display name
    }

    return self;
    
}

- (NSMutableDictionary *) parameters {
    
    if (!self.userID || !self.displayName)
        return nil;

    NSMutableDictionary *user = [[NSMutableDictionary alloc] init];
    [user dnSetObject:[self userID] forKey:DNRegistrationId];
    [user dnSetObject:[self displayName] forKey:DNUserRegistrationDisplayName];
    [user dnSetObject:[self emailAddress] forKey:DNUserRegistrationEmailAddress];
    [user dnSetObject:[self countryCode] forKey:DNUserRegistrationCountryCode];
    [user dnSetObject:[self mobileNumber] forKey:DNUserRegistrationMobileNumber];
    [user dnSetObject:[self firstName] forKey:DNFirstName];
    [user dnSetObject:[self lastName] forKey:DNLastName];
    [user dnSetObject:[self avatarAssetID] forKey:DNUserRegistrationAssetId];
    [user dnSetObject:[self additionalProperties] forKey:DNUserRegistrationAdditionalProperties];

    return user;
    
}

- (void)toggleTag:(NSString *)tag isSelected:(BOOL)selected {
    if (![self selectedTags])
        [self setSelectedTags:[[NSMutableArray alloc] init]];

    __block BOOL tagExists = NO;
    __block NSMutableArray *tagsCopy = [[self selectedTags] mutableCopy];
    [[self selectedTags] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *currentTag = [obj mutableCopy];
        if ([[currentTag valueForKey:@"value"] isEqualToString:tag]) {
            [currentTag dnSetObject:tag forKey:@"value"];
            [currentTag dnSetObject:@(selected) forKey:@"isSelected"];
            tagExists = YES;
            tagsCopy[idx] = currentTag;
        }
    }];

    [self setSelectedTags:tagsCopy];

    if (!tagExists)
        DNErrorLog(@"No tag found for: %@", tag);
}

- (NSMutableArray *)tagsForNetwork {

    __block NSMutableArray *tags = [[NSMutableArray alloc] init];

    [[self selectedTags] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *currentTag = [obj mutableCopy];
        [currentTag dnSetObject:currentTag[@"value"] forKey:@"value"];
        [currentTag dnSetObject:[currentTag[@"isSelected"] boolValue] ? @"true" : @"false" forKey:@"isSelected"];
        [tags addObject:currentTag];
    }];

    return tags;
}

- (void)saveUserTags:(NSMutableArray *)tags {
    if (tags) {
        [tags enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            DNTag *tag = obj;
            [self toggleTag:[tag value] isSelected:[tag isSelected]];
        }];
    }
}


@end
