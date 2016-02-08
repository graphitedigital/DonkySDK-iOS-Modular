//
//  DNUserDetails.m
//  Core Container
//
//  Created by Donky Networks on 17/03/2015.
//  Copyright (c) 2015 Donky Networks Ltd. All rights reserved.
//

#if !__has_feature(objc_arc)
#error Donky SDK must be built with ARC.
// You can turn on ARC for only Donky Class files by adding -fobjc-arc to the build phase for each of its files.
#endif

#import "DNUserDetails.h"
#import "NSMutableDictionary+DNDictionary.h"
#import "DNLoggingController.h"
#import "DNTag.h"

static NSString *const DNUserRegistrationDisplayName = @"displayName";
static NSString *const DNUserRegistrationEmailAddress = @"emailAddress";
static NSString *const DNUserRegistrationCountryCode = @"countryCode";
static NSString *const DNUserRegistrationMobileNumber = @"mobileNumber";
static NSString *const DNLastName = @"lastName";
static NSString *const DNFirstName = @"firstName";
static NSString *const DNUserRegistrationAssetID = @"avatarAssetId";
static NSString *const DNUserRegistrationAdditionalProperties = @"additionalProperties";
static NSString *const DNRegistrationID = @"id";

@interface DNUserDetails ()
@property(nonatomic, readwrite) NSString *userID;
@property(nonatomic, readwrite, getter=isAnonymous) BOOL anonymous;
@property(nonatomic, readwrite) NSString *networkProfileID;
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
        [self setNetworkProfileID:[deviceUser networkProfileID]];
        [self setAnonymous:[[deviceUser isAnonymous] boolValue]];
        [self setDisplayName:[deviceUser displayName]];
        [self setEmailAddress:[deviceUser emailAddress]];
        [self setMobileNumber:[deviceUser mobileNumber]];
        [self setCountryCode:[deviceUser countryCode]];
        [self setFirstName:[deviceUser firstName]];
        [self setLastName:[deviceUser lastName]];
        [self setAvatarAssetID:[deviceUser avatarAssetID]];
        [self setSelectedTags:[[deviceUser selectedTags] mutableCopy]];
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
        [self setSelectedTags:[selectedTags mutableCopy]];
        [self setAdditionalProperties:additionalProperties];
        [self setAnonymous:isAnonymous];
    }

    return self;
}

- (instancetype)initWithUserID:(NSString *)userID displayName:(NSString *)displayName emailAddress:(NSString *)emailAddress mobileNumber:(NSString *)mobileNumber countryCode:(NSString *)countryCode firstName:(NSString *)firstName lastName:(NSString *)lastName avatarID:(NSString *)avatarID selectedTags:(NSArray *)selectedTags additionalProperties:(NSDictionary *)additionalProperties {
    
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
        [self setSelectedTags:[selectedTags mutableCopy]];
        [self setAdditionalProperties:additionalProperties];
        [self setAnonymous:displayName == nil]; //We set to anonymous if there is no display name
    }

    return self;
    
}

- (NSMutableDictionary *) parameters {

    if (![self userID]) {
        DNErrorLog(@"No user ID for this user, returning nil.");
        return nil;
    }

    //Display name is required, guard against:
    if (![self displayName] && [self userID]) {
        //If no display name is set, use the userID.
        [self setDisplayName:[self userID]];
    }

    NSMutableDictionary *user = [[NSMutableDictionary alloc] init];
    [user dnSetObject:[self userID] forKey:DNRegistrationID];
    [user dnSetObject:[self displayName] forKey:DNUserRegistrationDisplayName];
    [user dnSetObject:[self emailAddress] forKey:DNUserRegistrationEmailAddress];
    [user dnSetObject:[self countryCode] forKey:DNUserRegistrationCountryCode];
    [user dnSetObject:[self mobileNumber] forKey:DNUserRegistrationMobileNumber];
    [user dnSetObject:[self firstName] forKey:DNFirstName];
    [user dnSetObject:[self lastName] forKey:DNLastName];
    [user dnSetObject:[self avatarAssetID] forKey:DNUserRegistrationAssetID];
    [user dnSetObject:[self additionalProperties] forKey:DNUserRegistrationAdditionalProperties];

    return user;
    
}

- (BOOL)toggleTag:(NSString *)tag isSelected:(BOOL)selected {
    if (![self selectedTags]) {
        [self setSelectedTags:[[NSMutableArray alloc] init]];
    }

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

    return tagExists;
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
        NSMutableArray *selectedTagsCopy = [[self selectedTags] mutableCopy];
        [tags enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            DNTag *tag = obj;
            if (![self toggleTag:[tag value] isSelected:[tag isSelected]]) {
                DNErrorLog(@"No tag found for: %@\nWill create and save it.", tag);
                NSMutableDictionary *currentTag = [[NSMutableDictionary alloc] init];
                [currentTag dnSetObject:[tag value] forKey:@"value"];
                [currentTag dnSetObject:@([tag isSelected]) forKey:@"isSelected"];
                [selectedTagsCopy addObject:currentTag];
            }
        }];
        [self setSelectedTags:selectedTagsCopy];
    }
}

#pragma mark - 
#pragma mark - Getters

- (NSDictionary *)additionalProperties {
    
    if (!_additionalProperties) {
        _additionalProperties = [[NSDictionary alloc] init];
    }
    
    return _additionalProperties;
}


@end
