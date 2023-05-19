//
//  ORTwitterUser.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 30/10/2012.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ORTwitterUser : NSObject <NSCoding>

@property (assign, nonatomic) u_int64_t userID;
@property (copy, nonatomic) NSString *screenName;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *bio;
@property (copy, nonatomic) NSString *location;
@property (assign, nonatomic) BOOL isProtected;
@property (assign, nonatomic) BOOL isVerified;
@property (assign, nonatomic) BOOL isFollowing;
@property (copy, nonatomic) NSNumber *favoritesCount;
@property (copy, nonatomic) NSNumber *followersCount;
@property (copy, nonatomic) NSNumber *followingCount;
@property (copy, nonatomic) NSNumber *tweetCount;
@property (copy, nonatomic) NSString *profileBackgroundImageUrl;
@property (copy, nonatomic) NSString *profilePicUrl_mini;
@property (copy, nonatomic) NSString *profilePicUrl_normal;
@property (copy, nonatomic) NSString *profilePicUrl_bigger;
@property (copy, nonatomic) NSString *profilePicUrl_original;

+ (id)instanceWithJSON:(NSDictionary *)json;
+ (id)arrayWithJSON:(NSArray *)json;
- (id)initWithJSON:(NSDictionary *)json;
- (NSMutableDictionary *)proxyForJson;

- (id)initWithTwitterJSON:(NSDictionary *)jsonData;
- (void)parseTwitterJSON:(NSDictionary *)jsonData;

@end
