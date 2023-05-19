//
//  ORTweet.m
//  
//
//  Created by Thomas Purnell-Fisher on 1/22/13.
//  Copyright (c) 2013 Orooso Inc.. All rights reserved.
//

#import "ORTweet.h"

#import "ORTwitterEntities.h"
#import "ORTwitterUser.h"

@implementation ORTweet

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.contributors forKey:@"contributors"];
    [encoder encodeObject:self.coordinates forKey:@"coordinates"];
    [encoder encodeObject:self.createdAt forKey:@"createdAt"];
    [encoder encodeObject:self.entities forKey:@"entities"];
    [encoder encodeObject:[NSNumber numberWithBool:self.favorited] forKey:@"favorited"];
    [encoder encodeObject:self.geo forKey:@"geo"];
    [encoder encodeObject:self.oRTweetId forKey:@"oRTweetId"];
    [encoder encodeObject:self.idStr forKey:@"idStr"];
    [encoder encodeObject:self.inReplyToScreenName forKey:@"inReplyToScreenName"];
    [encoder encodeObject:self.inReplyToStatusId forKey:@"inReplyToStatusId"];
    [encoder encodeObject:self.inReplyToStatusIdStr forKey:@"inReplyToStatusIdStr"];
    [encoder encodeObject:self.inReplyToUserId forKey:@"inReplyToUserId"];
    [encoder encodeObject:self.inReplyToUserIdStr forKey:@"inReplyToUserIdStr"];
    [encoder encodeObject:self.place forKey:@"place"];
    [encoder encodeObject:self.retweetCount forKey:@"retweetCount"];
    [encoder encodeObject:[NSNumber numberWithBool:self.retweeted] forKey:@"retweeted"];
    [encoder encodeObject:self.source forKey:@"source"];
    [encoder encodeObject:self.text forKey:@"text"];
    [encoder encodeObject:[NSNumber numberWithBool:self.truncated] forKey:@"truncated"];
    [encoder encodeObject:self.user forKey:@"user"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init])) {
        self.contributors = [decoder decodeObjectForKey:@"contributors"];
        self.coordinates = [decoder decodeObjectForKey:@"coordinates"];
        self.createdAt = [decoder decodeObjectForKey:@"createdAt"];
        self.entities = [decoder decodeObjectForKey:@"entities"];
        self.favorited = [(NSNumber *)[decoder decodeObjectForKey:@"favorited"] boolValue];
        self.geo = [decoder decodeObjectForKey:@"geo"];
        self.oRTweetId = [decoder decodeObjectForKey:@"oRTweetId"];
        self.idStr = [decoder decodeObjectForKey:@"idStr"];
        self.inReplyToScreenName = [decoder decodeObjectForKey:@"inReplyToScreenName"];
        self.inReplyToStatusId = [decoder decodeObjectForKey:@"inReplyToStatusId"];
        self.inReplyToStatusIdStr = [decoder decodeObjectForKey:@"inReplyToStatusIdStr"];
        self.inReplyToUserId = [decoder decodeObjectForKey:@"inReplyToUserId"];
        self.inReplyToUserIdStr = [decoder decodeObjectForKey:@"inReplyToUserIdStr"];
        self.place = [decoder decodeObjectForKey:@"place"];
        self.retweetCount = [decoder decodeObjectForKey:@"retweetCount"];
        self.retweeted = [(NSNumber *)[decoder decodeObjectForKey:@"retweeted"] boolValue];
        self.source = [decoder decodeObjectForKey:@"source"];
        self.text = [decoder decodeObjectForKey:@"text"];
        self.truncated = [(NSNumber *)[decoder decodeObjectForKey:@"truncated"] boolValue];
        self.user = [decoder decodeObjectForKey:@"user"];
    }
    return self;
}

+ (ORTweet *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    ORTweet *instance = [[ORTweet alloc] init];
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
            self.entities = [ORTwitterEntities instanceFromDictionary:value];
        }

    } else if ([key isEqualToString:@"user"]) {

        if ([value isKindOfClass:[NSDictionary class]]) {
            self.user = [ORTwitterUser instanceFromDictionary:value];
        }

    } else {
        [super setValue:value forKey:key];
    }

}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{

    if ([key isEqualToString:@"created_at"]) {
        [self setValue:value forKey:@"createdAt"];
    } else if ([key isEqualToString:@"id"]) {
        [self setValue:value forKey:@"oRTweetId"];
    } else if ([key isEqualToString:@"id_str"]) {
        [self setValue:value forKey:@"idStr"];
    } else if ([key isEqualToString:@"in_reply_to_screen_name"]) {
        [self setValue:value forKey:@"inReplyToScreenName"];
    } else if ([key isEqualToString:@"in_reply_to_status_id"]) {
        [self setValue:value forKey:@"inReplyToStatusId"];
    } else if ([key isEqualToString:@"in_reply_to_status_id_str"]) {
        [self setValue:value forKey:@"inReplyToStatusIdStr"];
    } else if ([key isEqualToString:@"in_reply_to_user_id"]) {
        [self setValue:value forKey:@"inReplyToUserId"];
    } else if ([key isEqualToString:@"in_reply_to_user_id_str"]) {
        [self setValue:value forKey:@"inReplyToUserIdStr"];
    } else if ([key isEqualToString:@"retweet_count"]) {
        [self setValue:value forKey:@"retweetCount"];
    } else {
        [super setValue:value forUndefinedKey:key];
    }

}


- (NSDictionary *)dictionaryRepresentation
{

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    if (self.contributors) {
        [dictionary setObject:self.contributors forKey:@"contributors"];
    }

    if (self.coordinates) {
        [dictionary setObject:self.coordinates forKey:@"coordinates"];
    }

    if (self.createdAt) {
        [dictionary setObject:self.createdAt forKey:@"createdAt"];
    }

    if (self.entities) {
        [dictionary setObject:self.entities forKey:@"entities"];
    }

    [dictionary setObject:[NSNumber numberWithBool:self.favorited] forKey:@"favorited"];

    if (self.geo) {
        [dictionary setObject:self.geo forKey:@"geo"];
    }

    if (self.oRTweetId) {
        [dictionary setObject:self.oRTweetId forKey:@"oRTweetId"];
    }

    if (self.idStr) {
        [dictionary setObject:self.idStr forKey:@"idStr"];
    }

    if (self.inReplyToScreenName) {
        [dictionary setObject:self.inReplyToScreenName forKey:@"inReplyToScreenName"];
    }

    if (self.inReplyToStatusId) {
        [dictionary setObject:self.inReplyToStatusId forKey:@"inReplyToStatusId"];
    }

    if (self.inReplyToStatusIdStr) {
        [dictionary setObject:self.inReplyToStatusIdStr forKey:@"inReplyToStatusIdStr"];
    }

    if (self.inReplyToUserId) {
        [dictionary setObject:self.inReplyToUserId forKey:@"inReplyToUserId"];
    }

    if (self.inReplyToUserIdStr) {
        [dictionary setObject:self.inReplyToUserIdStr forKey:@"inReplyToUserIdStr"];
    }

    if (self.place) {
        [dictionary setObject:self.place forKey:@"place"];
    }

    if (self.retweetCount) {
        [dictionary setObject:self.retweetCount forKey:@"retweetCount"];
    }

    [dictionary setObject:[NSNumber numberWithBool:self.retweeted] forKey:@"retweeted"];

    if (self.source) {
        [dictionary setObject:self.source forKey:@"source"];
    }

    if (self.text) {
        [dictionary setObject:self.text forKey:@"text"];
    }

    [dictionary setObject:[NSNumber numberWithBool:self.truncated] forKey:@"truncated"];

    if (self.user) {
        [dictionary setObject:self.user forKey:@"user"];
    }

    return dictionary;

}

@end
