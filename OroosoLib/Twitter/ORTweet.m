//
//  ORTweet.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 30/10/2012.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "ORTweet.h"
#import "ORTwitterUser.h"
#import "ORTwitterHashtag.h"
#import "ORTwitterMention.h"
#import "ORURL.h"
#import "ISO8601DateFormatter.h"

@interface ORTweet ()

+ (NSDate *)dateWithTwitterString:(NSString *)string;

@end

@implementation ORTweet

- (NSString *)debugDescription
{
    NSMutableString *desc = [NSMutableString stringWithFormat:
                             @"From: %@ (@%@)\n"
                              "Text: %@\n"
                              "Created At: %@\n"
                              "ID: %lld\n",
                             self.user.name, self.user.screenName, self.text, self.createdAt, self.tweetID];

    if (self.isRetweet) {
        [desc appendFormat:@"RT By: %@ (@%@) at %@\n", self.retweetUser.name, self.retweetUser.screenName, self.retweetedAt];
    }
    
    if (self.inReplyToTweetID > 0) {
        [desc appendFormat:@"In Reply To: %lld\n", self.inReplyToTweetID];
    }
    
    if ([self.media count] > 0) {
        [desc appendString:@"Media:\n"];
        for (ORURL *m in self.media) {
            [desc appendString:m.debugDescription];
        }
    }

    if ([self.urls count] > 0) {
        [desc appendString:@"URLs:\n"];
        for (ORURL *u in self.urls) {
            [desc appendString:u.debugDescription];
        }
    }
    
    if ([self.hashtags count] > 0) {
        [desc appendString:@"Hashtags:\n"];
        for (ORTwitterHashtag *h in self.hashtags) {
            [desc appendString:h.debugDescription];
        }
    }
    
    if ([self.userMentions count] > 0) {
        [desc appendString:@"User Mentions:\n"];
        for (ORTwitterMention *m in self.userMentions) {
            [desc appendString:m.debugDescription];
        }
    }

    [desc appendString:@"\n"];
    return desc;
}

+ (NSDate *)dateWithTwitterString:(NSString *)string
{
    static NSDateFormatter *formatter = nil;
    
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEE MMM dd HH:mm:ss ZZ yyyy";
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    }
    
	return [formatter dateFromString:string];
}

+ (id)instanceWithJSON:(NSDictionary *)json
{
    return [[self alloc] initWithJSON:json];
}

+ (id)arrayWithJSON:(NSArray *)json
{
    if (!json || ![json isKindOfClass:[NSArray class]]) return nil;
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:json.count];
    
    for (NSDictionary *dict in json) {
        id item = [self instanceWithJSON:dict];
        if (item) [items addObject:item];
    }
    
    return items;
}

- (id)initWithJSON:(NSDictionary *)json
{
    self = [super init];
    if (!self) return nil;
    if (!json || ![json isKindOfClass:[NSDictionary class]]) return nil;
    
    ISO8601DateFormatter *f = [[ISO8601DateFormatter alloc] init];
    
    self.tweetID = [[json valueForKey:@"TweetID"] unsignedLongLongValue];
    self.text = [json valueForKey:@"Text"];
    self.createdAt = [f dateFromString:[json valueForKey:@"CreatedAt"]];
    self.user = [ORTwitterUser instanceWithJSON:[json valueForKey:@"User"]];
    self.possiblySensitive = [[json valueForKey:@"PossiblySensitive"] boolValue];
    self.inReplyToTweetID = [[json valueForKey:@"InReplyToTweetID"] unsignedLongLongValue];
    self.inReplyToUserID = [[json valueForKey:@"InReplyToUserID"] unsignedLongLongValue];
    self.media = [ORURL arrayWithJSON:[json valueForKey:@"Media"]];
    self.urls = [ORURL arrayWithJSON:[json valueForKey:@"Urls"]];
    self.hashtags = [ORTwitterHashtag arrayWithJSON:[json valueForKey:@"Hashtags"]];
    self.userMentions = [ORTwitterMention arrayWithJSON:[json valueForKey:@"UserMentions"]];
    self.retweetedByMe = [[json valueForKey:@"RetweetedByMe"] boolValue];
    self.favoritedByMe = [[json valueForKey:@"FavoritedByMe"] boolValue];
    self.myRetweetID = [[json valueForKey:@"MyRetweetID"] unsignedLongLongValue];
    self.retweetID = [[json valueForKey:@"RetweetID"] unsignedLongLongValue];
    self.isRetweet = [[json valueForKey:@"IsRetweet"] boolValue];
    self.retweetUser = [ORTwitterUser instanceWithJSON:[json valueForKey:@"RetweetUser"]];
    self.retweetedAt = [f dateFromString:[json valueForKey:@"RetweetedAt"]];
    self.retweetCount = [[json valueForKey:@"RetweetCount"] integerValue];
    self.language = [json valueForKey:@"Language"];
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:19];
    ISO8601DateFormatter *f = [[ISO8601DateFormatter alloc] init];
    
    [d setValue:@(self.tweetID) forKey:@"TweetID"];
    [d setValue:self.text forKey:@"Text"];
    [d setValue:[f stringFromDate:self.createdAt] forKey:@"CreatedAt"];
    [d setValue:[self.user proxyForJson] forKey:@"User"];
    [d setValue:@(self.possiblySensitive) forKey:@"PossiblySensitive"];
    [d setValue:@(self.inReplyToTweetID) forKey:@"InReplyToTweetID"];
    [d setValue:@(self.inReplyToUserID) forKey:@"InReplyToUserID"];
    [d setValue:[ORURL proxyForJsonWithArray:self.media] forKey:@"Media"];
    [d setValue:[ORURL proxyForJsonWithArray:self.urls] forKey:@"Urls"];
    [d setValue:[ORTwitterHashtag proxyForJsonWithArray:self.hashtags] forKey:@"Hashtags"];
    [d setValue:[ORTwitterMention proxyForJsonWithArray:self.userMentions] forKey:@"UserMentions"];
    [d setValue:@(self.retweetedByMe) forKey:@"RetweetedByMe"];
    [d setValue:@(self.favoritedByMe) forKey:@"FavoritedByMe"];
    [d setValue:@(self.myRetweetID) forKey:@"MyRetweetID"];
    [d setValue:@(self.retweetID) forKey:@"RetweetID"];
    [d setValue:@(self.isRetweet) forKey:@"IsRetweet"];
    [d setValue:[self.retweetUser proxyForJson] forKey:@"RetweetUser"];
    [d setValue:[f stringFromDate:self.retweetedAt] forKey:@"RetweetedAt"];
    [d setValue:@(self.retweetCount) forKey:@"RetweetCount"];
    [d setValue:self.language forKey:@"Language"];
    
    return d;
}

- (id)initWithTwitterJSON:(NSDictionary *)jsonData
{
    self = [super init];
    if (self) [self parseTwitterJSON:jsonData];
    return self;
}

- (void)parseTwitterJSON:(NSDictionary *)jsonData
{
    // Check if this is a RT
    NSDictionary *json = [jsonData objectForKey:@"retweeted_status"];
    
    if (json && [json isKindOfClass:[NSDictionary class]]) {
        // We have a RT
        self.isRetweet = YES;
        self.retweetID = [[jsonData objectForKey:@"id"] unsignedLongLongValue];
        self.retweetedAt = [ORTweet dateWithTwitterString:[jsonData objectForKey:@"created_at"]];

        if ([[jsonData objectForKey:@"user"] isKindOfClass:[NSDictionary class]]) {
            self.retweetUser = [[ORTwitterUser alloc] initWithTwitterJSON:[jsonData objectForKey:@"user"]];
        }
    } else {
        // Normal Tweet
        json = jsonData;
        self.isRetweet = NO;
        self.retweetUser = nil;
        self.retweetedAt = nil;
    }
    
    self.tweetID = [[json objectForKey:@"id"] unsignedLongLongValue];
    self.text = [json objectForKey:@"text"];
    self.createdAt = [ORTweet dateWithTwitterString:[json objectForKey:@"created_at"]];
	self.retweetedByMe = [[json valueForKey:@"retweeted"] boolValue];
	self.favoritedByMe = [[json valueForKey:@"favorited"] boolValue];
    self.retweetCount = [[json objectForKey:@"retweet_count"] unsignedIntegerValue];
	self.favoriteCount = [[json objectForKey:@"favourites_count"] unsignedIntegerValue];
    self.language = [json objectForKey:@"lang"];
    
    if (![[json valueForKey:@"possibly_sensitive"] isKindOfClass:[NSNull class]]) {
        self.possiblySensitive = [[json valueForKey:@"possibly_sensitive"] boolValue];
    } else {
        self.possiblySensitive = NO;
    }
    
    if ([json valueForKey:@"current_user_retweet"]) {
        self.myRetweetID = [[json valueForKeyPath:@"current_user_retweet.id"] unsignedLongLongValue];
    } else {
        self.myRetweetID = 0;
    }
    
    if ([[json objectForKey:@"user"] isKindOfClass:[NSDictionary class]]) {
        self.user = [[ORTwitterUser alloc] initWithTwitterJSON:[json objectForKey:@"user"]];
    }
    
    // Twitter bug: RT from a user that doesn't exist anymore? 
    if (!self.user) self.user = self.retweetUser;
    
    if ([[json objectForKey:@"in_reply_to_status_id"] isKindOfClass:[NSNull class]]) {
        self.inReplyToTweetID = 0;
        self.inReplyToUserID = 0;
    } else {
        self.inReplyToTweetID = [[json objectForKey:@"in_reply_to_status_id"] unsignedLongLongValue];
        self.inReplyToUserID = [[json objectForKey:@"in_reply_to_user_id"] unsignedLongLongValue];
    }

    self.media = nil;
    if ([[json valueForKeyPath:@"entities.media"] isKindOfClass:[NSArray class]]) {
        self.media = [NSMutableArray arrayWithCapacity:[[json valueForKeyPath:@"entities.media"] count]];
        
        for (NSDictionary *obj in [json valueForKeyPath:@"entities.media"]) {
            ORURL *media = [ORURL URLWithTwitterMedia:obj];
            [self.media addObject:media];
        }
    }

    self.urls = nil;
    if ([[json valueForKeyPath:@"entities.urls"] isKindOfClass:[NSArray class]]) {
        self.urls = [NSMutableArray arrayWithCapacity:[[json valueForKeyPath:@"entities.urls"] count]];
        
        for (NSDictionary *obj in [json valueForKeyPath:@"entities.urls"]) {
            ORURL *url = [ORURL URLWithTwitterURL:obj];
            [self.urls addObject:url];
        }
    }

    self.hashtags = nil;
    if ([[json valueForKeyPath:@"entities.hashtags"] isKindOfClass:[NSArray class]]) {
        self.hashtags = [NSMutableArray arrayWithCapacity:[[json valueForKeyPath:@"entities.hashtags"] count]];
        
        for (NSDictionary *obj in [json valueForKeyPath:@"entities.hashtags"]) {
            ORTwitterHashtag *hashtag = [[ORTwitterHashtag alloc] initWithTwitterJSON:obj];
            [self.hashtags addObject:hashtag];
        }
    }

    self.userMentions = nil;
    if ([[json valueForKeyPath:@"entities.user_mentions"] isKindOfClass:[NSArray class]]) {
        self.userMentions = [NSMutableArray arrayWithCapacity:[[json valueForKeyPath:@"entities.user_mentions"] count]];
        
        for (NSDictionary *obj in [json valueForKeyPath:@"entities.user_mentions"]) {
            ORTwitterMention *mention = [[ORTwitterMention alloc] initWithTwitterJSON:obj];
            [self.userMentions addObject:mention];
        }
    }
}

- (ORURL*)firstURL
{
	if (!self.urls) return nil;
	if (self.urls.count == 0) return nil;
	return [self.urls objectAtIndex:0];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)c
{
    [c encodeInt64:self.tweetID forKey:@"tweetID"];
    [c encodeObject:self.text forKey:@"text"];
    [c encodeObject:self.createdAt forKey:@"createdAt"];
    [c encodeObject:self.user forKey:@"user"];
    [c encodeBool:self.possiblySensitive forKey:@"possiblySensitive"];
    [c encodeInt64:self.inReplyToTweetID forKey:@"inReplyToTweetID"];
    [c encodeInt64:self.inReplyToUserID forKey:@"inReplyToUserID"];
    [c encodeObject:self.media forKey:@"media"];
    [c encodeObject:self.urls forKey:@"urls"];
    [c encodeObject:self.hashtags forKey:@"hashtags"];
    [c encodeObject:self.userMentions forKey:@"userMentions"];
    [c encodeBool:self.retweetedByMe forKey:@"retweetedByMe"];
    [c encodeBool:self.favoritedByMe forKey:@"favoritedByMe"];
    [c encodeInt64:self.myRetweetID forKey:@"myRetweetID"];
    [c encodeInt64:self.retweetID forKey:@"retweetID"];
    [c encodeBool:self.isRetweet forKey:@"isRetweet"];
    [c encodeObject:self.retweetUser forKey:@"retweetUser"];
    [c encodeObject:self.retweetedAt forKey:@"retweetedAt"];
    [c encodeInteger:self.retweetCount forKey:@"retweetCount"];
    [c encodeObject:self.conversationTweets forKey:@"conversationTweets"];
    [c encodeObject:self.language forKey:@"language"];
}

- (id)initWithCoder:(NSCoder *)d
{
    self = [super init];
    if (!self) return nil;
    
    self.tweetID = [d decodeInt64ForKey:@"tweetID"];
    self.text = [d decodeObjectForKey:@"text"];
    self.createdAt = [d decodeObjectForKey:@"createdAt"];
    self.user = [d decodeObjectForKey:@"user"];
    self.possiblySensitive = [d decodeBoolForKey:@"possiblySensitive"];
    self.inReplyToTweetID = [d decodeInt64ForKey:@"inReplyToTweetID"];
    self.inReplyToUserID = [d decodeInt64ForKey:@"inReplyToUserID"];
    self.media = [d decodeObjectForKey:@"media"];
    self.urls = [d decodeObjectForKey:@"urls"];
    self.hashtags = [d decodeObjectForKey:@"hashtags"];
    self.userMentions = [d decodeObjectForKey:@"userMentions"];
    self.retweetedByMe = [d decodeBoolForKey:@"retweetedByMe"];
    self.favoritedByMe = [d decodeBoolForKey:@"favoritedByMe"];
    self.myRetweetID = [d decodeInt64ForKey:@"myRetweetID"];
    self.retweetID = [d decodeInt64ForKey:@"retweetID"];
    self.isRetweet = [d decodeBoolForKey:@"isRetweet"];
    self.retweetUser = [d decodeObjectForKey:@"retweetUser"];
    self.retweetedAt = [d decodeObjectForKey:@"retweetedAt"];
    self.retweetCount = [d decodeIntegerForKey:@"retweetCount"];
    self.conversationTweets = [d decodeObjectForKey:@"conversationTweets"];
    self.language = [d decodeObjectForKey:@"language"];
    
    return self;
}

- (NSUInteger)hash
{
    return self.tweetID;
}

- (BOOL)isEqual:(id)object
{
    if (self == object) return YES;
    if (![object isKindOfClass:[self class]]) return NO;
    
    return ([self tweetID] == [object tweetID]);
}

@end
