//
//  ORSFTweetURL.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 03/05/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFTwitterURL.h"
#import "ORTweet.h"
#import "ORTwitterUser.h"
#import "ORURLResolver.h"
#import "ORURL.h"

@implementation ORSFTwitterURL

- (id)initWithJSON:(NSDictionary *)json
{
    self = [super initWithJSON:json];
    if (!self) return nil;
    
    self.tweet = [ORTweet instanceWithJSON:[json valueForKey:@"Tweet"]];
    [self addTweet:self.tweet];
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [super proxyForJson];
    
    [d setValue:[self.tweet proxyForJson] forKey:@"Tweet"];
    
    return d;
}

- (id)initEmptyWithId:(NSString *)itemID
{
    self = [super init];
    if (!self) return nil;
    
    self.itemID = itemID;
    return self;
}

- (id)initWithTweet:(ORTweet *)tweet andEntity:(OREntity *)entity
{
    self = [super init];
    
    if (self) {
        self.tweet = tweet;
        self.parentEntity = entity;
        self.type = SFItemTypeTwitterURL;
        self.itemID = [NSString stringWithFormat:@"%lld", tweet.tweetID];
        self.title = tweet.user.name;
        self.content = tweet.text;
        
        if (tweet.urls.count > 0) {
            self.detailURL = tweet.urls[0];
            self.detailURL = [[ORURLResolver sharedInstance] findOnCache:self.detailURL];
            
            self.detailURL.originalURL = self.detailURL.finalURL;
            [self.detailURL replaceKnownQueryParams];
            
            if (!self.detailURL.isResolved) {
                [[ORURLResolver sharedInstance] resolveORURL:self.detailURL localOnly:YES completion:^(NSError *error, ORURL *finalURL) {
                    if (finalURL) self.detailURL = finalURL;
                }];
            }
            
            self.itemID = self.detailURL.finalURL.absoluteString;
        }
        
        if (self.detailURL.imageURL) self.imageURL = self.detailURL.imageURL;
        [self addTweet:tweet];
    }
    
    return self;
}

- (void)setRawScores
{
    self.scoreBlendedNormalized = 0;
    
    for (ORTweet *tweet in self.tweets) {
        self.scoreBlendedNormalized += (tweet.retweetCount + tweet.favoriteCount + 1);
    }
}

- (void)addTweet:(ORTweet *)tweet
{
    if (!self.tweets) self.tweets = [NSMutableOrderedSet orderedSetWithCapacity:1];
    
    if (tweet) {
        NSUInteger idx = [self.tweets indexOfObject:tweet];

        if (idx == NSNotFound) {
            [self.tweets addObject:tweet];
        } else {
            self.tweets[idx] = tweet;
        }
        
        NSDate *tweetDate = (tweet.retweetedAt) ? tweet.retweetedAt : tweet.createdAt;
        if (!self.lastActivity || [tweetDate compare:self.lastActivity] == NSOrderedDescending) {
            self.lastActivity = tweetDate;
        }
    }
}

- (void)cancelPendingOperations
{
    [super cancelPendingOperations];
    self.detailURL.isResolving = NO;
}

#pragma mark - NSCoder

- (void)encodeWithCoder:(NSCoder *)c
{
    [super encodeWithCoder:c];
    
    [c encodeObject:self.tweet forKey:@"tweet"];
    [c encodeObject:self.tweets forKey:@"tweets"];
    [c encodeObject:self.lastActivity forKey:@"lastActivity"];
}

- (id)initWithCoder:(NSCoder *)d
{
    self = [super initWithCoder:d];
    if (!self) return nil;
    
    self.tweet = [d decodeObjectForKey:@"tweet"];
    self.lastActivity = [d decodeObjectForKey:@"lastActivity"];
    
    if ([d decodeObjectForKey:@"tweets"]) {
        if ([[d decodeObjectForKey:@"tweets"] isKindOfClass:[NSArray class]]) {
            self.tweets = [NSMutableOrderedSet orderedSetWithArray:[d decodeObjectForKey:@"tweets"]];
        } else {
            self.tweets = [NSMutableOrderedSet orderedSetWithOrderedSet:[d decodeObjectForKey:@"tweets"]];
        }
    } else {
        [self addTweet:self.tweet];
    }
    
    if (!self.lastActivity) {
        for (ORTweet *tweet in self.tweets) {
            NSDate *tweetDate = (tweet.retweetedAt) ? tweet.retweetedAt : tweet.createdAt;
            if (!self.lastActivity || [tweetDate compare:self.lastActivity] == NSOrderedDescending) {
                self.lastActivity = tweetDate;
            }
        }
    }
    
    return self;
}

@end
