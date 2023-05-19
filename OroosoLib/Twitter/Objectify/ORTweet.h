//
//  ORTweet.h
//  
//
//  Created by Thomas Purnell-Fisher on 1/22/13.
//  Copyright (c) 2013 Orooso Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ORTwitterEntities;
@class ORTwitterUser;

@interface ORTweet : NSObject <NSCoding>

@property (nonatomic, strong) id contributors;
@property (nonatomic, strong) id coordinates;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, strong) ORTwitterEntities *entities;
@property (nonatomic, assign) BOOL favorited;
@property (nonatomic, strong) id geo;
@property (nonatomic, copy) NSNumber *oRTweetId;
@property (nonatomic, copy) NSString *idStr;
@property (nonatomic, strong) id inReplyToScreenName;
@property (nonatomic, strong) id inReplyToStatusId;
@property (nonatomic, strong) id inReplyToStatusIdStr;
@property (nonatomic, strong) id inReplyToUserId;
@property (nonatomic, strong) id inReplyToUserIdStr;
@property (nonatomic, strong) id place;
@property (nonatomic, copy) NSNumber *retweetCount;
@property (nonatomic, assign) BOOL retweeted;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) BOOL truncated;
@property (nonatomic, strong) ORTwitterUser *user;


+ (ORTweet *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

- (NSDictionary *)dictionaryRepresentation;

@end
