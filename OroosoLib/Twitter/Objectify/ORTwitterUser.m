//
//  ORTwitterUser.m
//  
//
//  Created by Thomas Purnell-Fisher on 1/22/13.
//  Copyright (c) 2013 Orooso Inc.. All rights reserved.
//

#import "ORTwitterUser.h"

#import "ORTwitterUserEntities.h"

@implementation ORTwitterUser

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:[NSNumber numberWithBool:self.contributorsEnabled] forKey:@"contributorsEnabled"];
    [encoder encodeObject:self.createdAt forKey:@"createdAt"];
    [encoder encodeObject:[NSNumber numberWithBool:self.defaultProfile] forKey:@"defaultProfile"];
    [encoder encodeObject:[NSNumber numberWithBool:self.defaultProfileImage] forKey:@"defaultProfileImage"];
    [encoder encodeObject:self.descriptionText forKey:@"descriptionText"];
    [encoder encodeObject:self.entities forKey:@"entities"];
    [encoder encodeObject:self.favouritesCount forKey:@"favouritesCount"];
    [encoder encodeObject:self.followRequestSent forKey:@"followRequestSent"];
    [encoder encodeObject:self.followersCount forKey:@"followersCount"];
    [encoder encodeObject:[NSNumber numberWithBool:self.following] forKey:@"following"];
    [encoder encodeObject:self.friendsCount forKey:@"friendsCount"];
    [encoder encodeObject:[NSNumber numberWithBool:self.geoEnabled] forKey:@"geoEnabled"];
    [encoder encodeObject:self.oRTwitterUserId forKey:@"oRTwitterUserId"];
    [encoder encodeObject:self.idStr forKey:@"idStr"];
    [encoder encodeObject:[NSNumber numberWithBool:self.isTranslator] forKey:@"isTranslator"];
    [encoder encodeObject:self.lang forKey:@"lang"];
    [encoder encodeObject:self.listedCount forKey:@"listedCount"];
    [encoder encodeObject:self.location forKey:@"location"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.notifications forKey:@"notifications"];
    [encoder encodeObject:self.profileBackgroundColor forKey:@"profileBackgroundColor"];
    [encoder encodeObject:self.profileBackgroundImageUrl forKey:@"profileBackgroundImageUrl"];
    [encoder encodeObject:self.profileBackgroundImageUrlHttps forKey:@"profileBackgroundImageUrlHttps"];
    [encoder encodeObject:[NSNumber numberWithBool:self.profileBackgroundTile] forKey:@"profileBackgroundTile"];
    [encoder encodeObject:self.profileImageUrl forKey:@"profileImageUrl"];
    [encoder encodeObject:self.profileImageUrlHttps forKey:@"profileImageUrlHttps"];
    [encoder encodeObject:self.profileLinkColor forKey:@"profileLinkColor"];
    [encoder encodeObject:self.profileSidebarBorderColor forKey:@"profileSidebarBorderColor"];
    [encoder encodeObject:self.profileSidebarFillColor forKey:@"profileSidebarFillColor"];
    [encoder encodeObject:self.profileTextColor forKey:@"profileTextColor"];
    [encoder encodeObject:[NSNumber numberWithBool:self.profileUseBackgroundImage] forKey:@"profileUseBackgroundImage"];
    [encoder encodeObject:[NSNumber numberWithBool:self.protected] forKey:@"protected"];
    [encoder encodeObject:self.screenName forKey:@"screenName"];
    [encoder encodeObject:self.statusesCount forKey:@"statusesCount"];
    [encoder encodeObject:self.timeZone forKey:@"timeZone"];
    [encoder encodeObject:self.url forKey:@"url"];
    [encoder encodeObject:self.utcOffset forKey:@"utcOffset"];
    [encoder encodeObject:[NSNumber numberWithBool:self.verified] forKey:@"verified"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init])) {
        self.contributorsEnabled = [(NSNumber *)[decoder decodeObjectForKey:@"contributorsEnabled"] boolValue];
        self.createdAt = [decoder decodeObjectForKey:@"createdAt"];
        self.defaultProfile = [(NSNumber *)[decoder decodeObjectForKey:@"defaultProfile"] boolValue];
        self.defaultProfileImage = [(NSNumber *)[decoder decodeObjectForKey:@"defaultProfileImage"] boolValue];
        self.descriptionText = [decoder decodeObjectForKey:@"descriptionText"];
        self.entities = [decoder decodeObjectForKey:@"entities"];
        self.favouritesCount = [decoder decodeObjectForKey:@"favouritesCount"];
        self.followRequestSent = [decoder decodeObjectForKey:@"followRequestSent"];
        self.followersCount = [decoder decodeObjectForKey:@"followersCount"];
        self.following = [(NSNumber *)[decoder decodeObjectForKey:@"following"] boolValue];
        self.friendsCount = [decoder decodeObjectForKey:@"friendsCount"];
        self.geoEnabled = [(NSNumber *)[decoder decodeObjectForKey:@"geoEnabled"] boolValue];
        self.oRTwitterUserId = [decoder decodeObjectForKey:@"oRTwitterUserId"];
        self.idStr = [decoder decodeObjectForKey:@"idStr"];
        self.isTranslator = [(NSNumber *)[decoder decodeObjectForKey:@"isTranslator"] boolValue];
        self.lang = [decoder decodeObjectForKey:@"lang"];
        self.listedCount = [decoder decodeObjectForKey:@"listedCount"];
        self.location = [decoder decodeObjectForKey:@"location"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.notifications = [decoder decodeObjectForKey:@"notifications"];
        self.profileBackgroundColor = [decoder decodeObjectForKey:@"profileBackgroundColor"];
        self.profileBackgroundImageUrl = [decoder decodeObjectForKey:@"profileBackgroundImageUrl"];
        self.profileBackgroundImageUrlHttps = [decoder decodeObjectForKey:@"profileBackgroundImageUrlHttps"];
        self.profileBackgroundTile = [(NSNumber *)[decoder decodeObjectForKey:@"profileBackgroundTile"] boolValue];
        self.profileImageUrl = [decoder decodeObjectForKey:@"profileImageUrl"];
        self.profileImageUrlHttps = [decoder decodeObjectForKey:@"profileImageUrlHttps"];
        self.profileLinkColor = [decoder decodeObjectForKey:@"profileLinkColor"];
        self.profileSidebarBorderColor = [decoder decodeObjectForKey:@"profileSidebarBorderColor"];
        self.profileSidebarFillColor = [decoder decodeObjectForKey:@"profileSidebarFillColor"];
        self.profileTextColor = [decoder decodeObjectForKey:@"profileTextColor"];
        self.profileUseBackgroundImage = [(NSNumber *)[decoder decodeObjectForKey:@"profileUseBackgroundImage"] boolValue];
        self.protected = [(NSNumber *)[decoder decodeObjectForKey:@"protected"] boolValue];
        self.screenName = [decoder decodeObjectForKey:@"screenName"];
        self.statusesCount = [decoder decodeObjectForKey:@"statusesCount"];
        self.timeZone = [decoder decodeObjectForKey:@"timeZone"];
        self.url = [decoder decodeObjectForKey:@"url"];
        self.utcOffset = [decoder decodeObjectForKey:@"utcOffset"];
        self.verified = [(NSNumber *)[decoder decodeObjectForKey:@"verified"] boolValue];
    }
    return self;
}

+ (ORTwitterUser *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    ORTwitterUser *instance = [[ORTwitterUser alloc] init];
    [instance setAttributesFromDictionary:aDictionary];
    return instance;

}

- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary
{

    if (![aDictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }

    [self setValuesForKeysWithDictionary:aDictionary];

}

- (void)setValue:(id)value forKey:(NSString *)key
{

    if ([key isEqualToString:@"entities"]) {

        if ([value isKindOfClass:[NSDictionary class]]) {
            self.entities = [ORTwitterUserEntities instanceFromDictionary:value];
        }

    } else {
        [super setValue:value forKey:key];
    }

}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{

    if ([key isEqualToString:@"contributors_enabled"]) {
        [self setValue:value forKey:@"contributorsEnabled"];
    } else if ([key isEqualToString:@"created_at"]) {
        [self setValue:value forKey:@"createdAt"];
    } else if ([key isEqualToString:@"default_profile"]) {
        [self setValue:value forKey:@"defaultProfile"];
    } else if ([key isEqualToString:@"default_profile_image"]) {
        [self setValue:value forKey:@"defaultProfileImage"];
    } else if ([key isEqualToString:@"description"]) {
        [self setValue:value forKey:@"descriptionText"];
    } else if ([key isEqualToString:@"favourites_count"]) {
        [self setValue:value forKey:@"favouritesCount"];
    } else if ([key isEqualToString:@"follow_request_sent"]) {
        [self setValue:value forKey:@"followRequestSent"];
    } else if ([key isEqualToString:@"followers_count"]) {
        [self setValue:value forKey:@"followersCount"];
    } else if ([key isEqualToString:@"friends_count"]) {
        [self setValue:value forKey:@"friendsCount"];
    } else if ([key isEqualToString:@"geo_enabled"]) {
        [self setValue:value forKey:@"geoEnabled"];
    } else if ([key isEqualToString:@"id"]) {
        [self setValue:value forKey:@"oRTwitterUserId"];
    } else if ([key isEqualToString:@"id_str"]) {
        [self setValue:value forKey:@"idStr"];
    } else if ([key isEqualToString:@"is_translator"]) {
        [self setValue:value forKey:@"isTranslator"];
    } else if ([key isEqualToString:@"listed_count"]) {
        [self setValue:value forKey:@"listedCount"];
    } else if ([key isEqualToString:@"profile_background_color"]) {
        [self setValue:value forKey:@"profileBackgroundColor"];
    } else if ([key isEqualToString:@"profile_background_image_url"]) {
        [self setValue:value forKey:@"profileBackgroundImageUrl"];
    } else if ([key isEqualToString:@"profile_background_image_url_https"]) {
        [self setValue:value forKey:@"profileBackgroundImageUrlHttps"];
    } else if ([key isEqualToString:@"profile_background_tile"]) {
        [self setValue:value forKey:@"profileBackgroundTile"];
    } else if ([key isEqualToString:@"profile_image_url"]) {
        [self setValue:value forKey:@"profileImageUrl"];
    } else if ([key isEqualToString:@"profile_image_url_https"]) {
        [self setValue:value forKey:@"profileImageUrlHttps"];
    } else if ([key isEqualToString:@"profile_link_color"]) {
        [self setValue:value forKey:@"profileLinkColor"];
    } else if ([key isEqualToString:@"profile_sidebar_border_color"]) {
        [self setValue:value forKey:@"profileSidebarBorderColor"];
    } else if ([key isEqualToString:@"profile_sidebar_fill_color"]) {
        [self setValue:value forKey:@"profileSidebarFillColor"];
    } else if ([key isEqualToString:@"profile_text_color"]) {
        [self setValue:value forKey:@"profileTextColor"];
    } else if ([key isEqualToString:@"profile_use_background_image"]) {
        [self setValue:value forKey:@"profileUseBackgroundImage"];
    } else if ([key isEqualToString:@"screen_name"]) {
        [self setValue:value forKey:@"screenName"];
    } else if ([key isEqualToString:@"statuses_count"]) {
        [self setValue:value forKey:@"statusesCount"];
    } else if ([key isEqualToString:@"time_zone"]) {
        [self setValue:value forKey:@"timeZone"];
    } else if ([key isEqualToString:@"utc_offset"]) {
        [self setValue:value forKey:@"utcOffset"];
    } else {
        [super setValue:value forUndefinedKey:key];
    }

}


- (NSDictionary *)dictionaryRepresentation
{

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    [dictionary setObject:[NSNumber numberWithBool:self.contributorsEnabled] forKey:@"contributorsEnabled"];

    if (self.createdAt) {
        [dictionary setObject:self.createdAt forKey:@"createdAt"];
    }

    [dictionary setObject:[NSNumber numberWithBool:self.defaultProfile] forKey:@"defaultProfile"];

    [dictionary setObject:[NSNumber numberWithBool:self.defaultProfileImage] forKey:@"defaultProfileImage"];

    if (self.descriptionText) {
        [dictionary setObject:self.descriptionText forKey:@"descriptionText"];
    }

    if (self.entities) {
        [dictionary setObject:self.entities forKey:@"entities"];
    }

    if (self.favouritesCount) {
        [dictionary setObject:self.favouritesCount forKey:@"favouritesCount"];
    }

    if (self.followRequestSent) {
        [dictionary setObject:self.followRequestSent forKey:@"followRequestSent"];
    }

    if (self.followersCount) {
        [dictionary setObject:self.followersCount forKey:@"followersCount"];
    }

    [dictionary setObject:[NSNumber numberWithBool:self.following] forKey:@"following"];

    if (self.friendsCount) {
        [dictionary setObject:self.friendsCount forKey:@"friendsCount"];
    }

    [dictionary setObject:[NSNumber numberWithBool:self.geoEnabled] forKey:@"geoEnabled"];

    if (self.oRTwitterUserId) {
        [dictionary setObject:self.oRTwitterUserId forKey:@"oRTwitterUserId"];
    }

    if (self.idStr) {
        [dictionary setObject:self.idStr forKey:@"idStr"];
    }

    [dictionary setObject:[NSNumber numberWithBool:self.isTranslator] forKey:@"isTranslator"];

    if (self.lang) {
        [dictionary setObject:self.lang forKey:@"lang"];
    }

    if (self.listedCount) {
        [dictionary setObject:self.listedCount forKey:@"listedCount"];
    }

    if (self.location) {
        [dictionary setObject:self.location forKey:@"location"];
    }

    if (self.name) {
        [dictionary setObject:self.name forKey:@"name"];
    }

    if (self.notifications) {
        [dictionary setObject:self.notifications forKey:@"notifications"];
    }

    if (self.profileBackgroundColor) {
        [dictionary setObject:self.profileBackgroundColor forKey:@"profileBackgroundColor"];
    }

    if (self.profileBackgroundImageUrl) {
        [dictionary setObject:self.profileBackgroundImageUrl forKey:@"profileBackgroundImageUrl"];
    }

    if (self.profileBackgroundImageUrlHttps) {
        [dictionary setObject:self.profileBackgroundImageUrlHttps forKey:@"profileBackgroundImageUrlHttps"];
    }

    [dictionary setObject:[NSNumber numberWithBool:self.profileBackgroundTile] forKey:@"profileBackgroundTile"];

    if (self.profileImageUrl) {
        [dictionary setObject:self.profileImageUrl forKey:@"profileImageUrl"];
    }

    if (self.profileImageUrlHttps) {
        [dictionary setObject:self.profileImageUrlHttps forKey:@"profileImageUrlHttps"];
    }

    if (self.profileLinkColor) {
        [dictionary setObject:self.profileLinkColor forKey:@"profileLinkColor"];
    }

    if (self.profileSidebarBorderColor) {
        [dictionary setObject:self.profileSidebarBorderColor forKey:@"profileSidebarBorderColor"];
    }

    if (self.profileSidebarFillColor) {
        [dictionary setObject:self.profileSidebarFillColor forKey:@"profileSidebarFillColor"];
    }

    if (self.profileTextColor) {
        [dictionary setObject:self.profileTextColor forKey:@"profileTextColor"];
    }

    [dictionary setObject:[NSNumber numberWithBool:self.profileUseBackgroundImage] forKey:@"profileUseBackgroundImage"];

    [dictionary setObject:[NSNumber numberWithBool:self.protected] forKey:@"protected"];

    if (self.screenName) {
        [dictionary setObject:self.screenName forKey:@"screenName"];
    }

    if (self.statusesCount) {
        [dictionary setObject:self.statusesCount forKey:@"statusesCount"];
    }

    if (self.timeZone) {
        [dictionary setObject:self.timeZone forKey:@"timeZone"];
    }

    if (self.url) {
        [dictionary setObject:self.url forKey:@"url"];
    }

    if (self.utcOffset) {
        [dictionary setObject:self.utcOffset forKey:@"utcOffset"];
    }

    [dictionary setObject:[NSNumber numberWithBool:self.verified] forKey:@"verified"];

    return dictionary;

}

@end
