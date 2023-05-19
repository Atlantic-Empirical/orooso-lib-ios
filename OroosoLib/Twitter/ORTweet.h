//
//  ORTweet.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 30/10/2012.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ORTwitterUser;
@class ORURL;

@interface ORTweet : NSObject <NSCoding>

@property (assign, nonatomic) u_int64_t tweetID;
@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) NSDate *createdAt;
@property (strong, nonatomic) ORTwitterUser *user;
@property (assign, nonatomic) BOOL possiblySensitive;
@property (copy, nonatomic) NSString *language;

// Reply
@property (assign, nonatomic) u_int64_t inReplyToTweetID;
@property (assign, nonatomic) u_int64_t inReplyToUserID;

// Entities
@property (strong, nonatomic) NSMutableArray *media;
@property (strong, nonatomic) NSMutableArray *urls;
@property (strong, nonatomic) NSMutableArray *hashtags;
@property (strong, nonatomic) NSMutableArray *userMentions;

// User relationships with Tweet
@property (assign, nonatomic) BOOL retweetedByMe;
@property (assign, nonatomic) BOOL favoritedByMe;
@property (assign, nonatomic) u_int64_t myRetweetID;

// Retweets
@property (assign, nonatomic) u_int64_t retweetID;
@property (assign, nonatomic) BOOL isRetweet;
@property (strong, nonatomic) ORTwitterUser *retweetUser;
@property (copy, nonatomic) NSDate *retweetedAt;
@property (assign, nonatomic) NSUInteger retweetCount;
@property (assign, nonatomic) NSUInteger favoriteCount;

// URL
@property (strong, nonatomic, readonly) ORURL *firstURL;

// Conversation
@property (strong, nonatomic) NSArray *conversationTweets;

+ (id)instanceWithJSON:(NSDictionary *)json;
+ (id)arrayWithJSON:(NSArray *)json;
- (id)initWithJSON:(NSDictionary *)json;
- (NSMutableDictionary *)proxyForJson;

- (id)initWithTwitterJSON:(NSDictionary *)jsonData;
- (void)parseTwitterJSON:(NSDictionary *)jsonData;

@end
