//
//  ORSFTweet.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 07/12/2012.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "ORSFTweet.h"
#import "ORTweet.h"
#import "ORTwitterUser.h"
#import "ORURL.h"

#define WEIGHTING_celebrity 1.0f
#define WEIGHTING_recency 1.0f
#define WEIGHTING_retweets 1.0f
#define WEIGHTING_following 1.0f
#define WEIGHTING_picture 1.0f
#define WEIGHTING_followers 1.0f

@implementation ORSFTweet

- (id)initWithJSON:(NSDictionary *)json
{
    self = [super initWithJSON:json];
    if (!self) return nil;
    
    _tweet = [ORTweet instanceWithJSON:[json valueForKey:@"Tweet"]];
    self.fullContent = [json valueForKey:@"FullContent"];
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [super proxyForJson];
    
    [d setValue:[self.tweet proxyForJson] forKey:@"Tweet"];
    [d setValue:self.fullContent forKey:@"FullContent"];
    
    return d;
}

- (id)initWithTweet:(ORTweet *)tweet andEntity:(OREntity *)entity
{
    self = [super init];
    if (!self) return nil;
    
    self.tweet = tweet;
    self.parentEntity = entity;
    
    return self;
}

- (void)setTweet:(ORTweet *)tweet
{
    if (_tweet == tweet) return;
    _tweet = tweet;
    
    self.type = SFItemTypeTweet;
    self.itemID = [NSString stringWithFormat:@"%lld", tweet.tweetID];
    self.title = tweet.user.name;
    self.avatarURL = [NSURL URLWithString:tweet.user.profilePicUrl_normal];
    
    NSString *tweetContent = tweet.text;
    NSString *fullContent = tweet.text;
    
    if (tweet.urls.count > 0) {
        self.otherURLs = [NSMutableArray arrayWithCapacity:tweet.urls.count];
        
        // Sets the first URL as the item's main URL and store them to parse later
        for (ORURL *obj in tweet.urls) {
            if (!self.detailURL) self.detailURL = obj;
            [self.otherURLs addObject:obj];
        }
    }

    // Sets the first Media URL as the item's main image
    for (ORURL *obj in tweet.media) {
        if (!self.imageURL) {
            self.imageURL = obj.imageURL;
            self.detailURL = nil;
            break;
        }
    }
    
    self.content = tweetContent;
    self.fullContent = fullContent;
}

- (void)setRawScores
{
    self.rawSubscores = [NSMutableDictionary dictionaryWithCapacity:6];
    self.subscoreWeights = [NSMutableDictionary dictionaryWithCapacity:6];
    
    // 1. Is Celebrity?
    [self.rawSubscores setObject:@(self.tweet.user.isVerified) forKey:@"celebrity"];
    [self.subscoreWeights setObject:@(WEIGHTING_celebrity) forKey:@"celebrity"];
    
    // 2. Recency
    NSTimeInterval timeInterval = [self.tweet.createdAt timeIntervalSinceNow];
	[self.rawSubscores setObject:@(timeInterval) forKey:@"recency"];
    [self.subscoreWeights setObject:@(WEIGHTING_recency) forKey:@"recency"];
    
    // 3. Retweet Count
	[self.rawSubscores setObject:@(self.tweet.retweetCount + self.tweet.favoriteCount) forKey:@"retweets"];
    [self.subscoreWeights setObject:@(WEIGHTING_retweets) forKey:@"retweets"];
    
    // 4. Am Following?
    [self.rawSubscores setObject:@(self.tweet.user.isFollowing) forKey:@"following"];
    [self.subscoreWeights setObject:@(WEIGHTING_following) forKey:@"following"];
    
    // 5. Has Picture?
    [self.rawSubscores setObject:@((self.tweet.media.count > 0)) forKey:@"picture"];
    [self.subscoreWeights setObject:@(WEIGHTING_picture) forKey:@"picture"];
    
    // 6. Followers Count - only if it's not nil
    if (self.tweet.user.followersCount) {
        [self.rawSubscores setObject:self.tweet.user.followersCount forKey:@"followers"];
        [self.subscoreWeights setObject:@(WEIGHTING_followers) forKey:@"followers"];
    }
}

#pragma mark - NSCoder

- (void)encodeWithCoder:(NSCoder *)c
{
    [super encodeWithCoder:c];
    
    [c encodeObject:self.tweet forKey:@"tweet"];
    [c encodeObject:self.fullContent forKey:@"fullContent"];
}

- (id)initWithCoder:(NSCoder *)d
{
    self = [super initWithCoder:d];
    if (!self) return nil;
    
    _tweet = [d decodeObjectForKey:@"tweet"];
    self.fullContent = [d decodeObjectForKey:@"fullContent"];
    
    return self;
}

@end
