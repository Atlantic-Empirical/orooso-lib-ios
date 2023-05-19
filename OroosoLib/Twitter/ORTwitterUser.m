//
//  ORTwitterUser.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 30/10/2012.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "ORTwitterUser.h"

@implementation ORTwitterUser

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
    
    self.userID = [[json valueForKey:@"UserID"] unsignedLongLongValue];
    self.screenName = [json valueForKey:@"ScreenName"];
    self.name = [json valueForKey:@"Name"];
    self.bio = [json valueForKey:@"Bio"];
    self.location = [json valueForKey:@"Location"];
    self.isProtected = [[json valueForKey:@"Protected"] boolValue];
    self.isVerified = [[json valueForKey:@"Verified"] boolValue];
    self.isFollowing = [[json valueForKey:@"Following"] boolValue];
    self.favoritesCount = [json valueForKey:@"FavoritesCount"];
    self.followersCount = [json valueForKey:@"FollowersCount"];
    self.followingCount = [json valueForKey:@"FollowingCount"];
    self.tweetCount = [json valueForKey:@"TweetCount"];
    self.profileBackgroundImageUrl = [json valueForKey:@"ProfileBackgroundImageUrl"];
    self.profilePicUrl_normal = [json valueForKey:@"ProfilePicUrl"];
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:14];
    
    [d setValue:@(self.userID) forKey:@"UserID"];
    [d setValue:self.screenName forKey:@"ScreenName"];
    [d setValue:self.name forKey:@"Name"];
    [d setValue:self.bio forKey:@"Bio"];
    [d setValue:self.location forKey:@"Location"];
    [d setValue:@(self.isProtected) forKey:@"Protected"];
    [d setValue:@(self.isVerified) forKey:@"Verified"];
    [d setValue:@(self.isFollowing) forKey:@"Following"];
    [d setValue:self.favoritesCount forKey:@"FavoritesCount"];
    [d setValue:self.followersCount forKey:@"FollowersCount"];
    [d setValue:self.followingCount forKey:@"FollowingCount"];
    [d setValue:self.tweetCount forKey:@"TweetCount"];
    [d setValue:self.profileBackgroundImageUrl forKey:@"ProfileBackgroundImageUrl"];
    [d setValue:self.profilePicUrl_normal forKey:@"ProfilePicUrl"];
    
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
    self.userID = [[jsonData objectForKey:@"id"] unsignedLongLongValue];
    self.screenName = [jsonData objectForKey:@"screen_name"];
    self.name = [jsonData objectForKey:@"name"];
    self.bio = [jsonData objectForKey:@"description"];
    self.location = [jsonData objectForKey:@"location"];
    self.profilePicUrl_normal = [jsonData objectForKey:@"profile_image_url"];
	self.profileBackgroundImageUrl = [jsonData objectForKey:@"profile_background_image_url"];
    self.isProtected = [[jsonData valueForKey:@"protected"] boolValue];
    self.isVerified = [[jsonData valueForKey:@"verified"] boolValue];
	self.favoritesCount = [jsonData objectForKey:@"favourites_count"];
    self.followersCount = [jsonData objectForKey:@"followers_count"];
    self.followingCount = [jsonData objectForKey:@"friends_count"];
    self.tweetCount = [jsonData objectForKey:@"statuses_count"];
    
    if ([[jsonData valueForKey:@"following"] isKindOfClass:[NSNull class]]) {
        self.isFollowing = NO;
    } else {
        self.isFollowing = [[jsonData valueForKey:@"following"] boolValue];
    }
}

- (NSString*)profilePicUrl_mini{
	return [self.profilePicUrl_normal stringByReplacingOccurrencesOfString:@"_normal" withString:@"_mini"];
}

- (NSString*)profilePicUrl_bigger{
	return [self.profilePicUrl_normal stringByReplacingOccurrencesOfString:@"_normal" withString:@"_bigger"];
}

- (NSString*)profilePicUrl_original{
	return [self.profilePicUrl_normal stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)c
{
    [c encodeInt64:self.userID forKey:@"userID"];
    [c encodeObject:self.screenName forKey:@"screenName"];
    [c encodeObject:self.name forKey:@"name"];
    [c encodeObject:self.bio forKey:@"bio"];
    [c encodeObject:self.location forKey:@"location"];
    [c encodeBool:self.isProtected forKey:@"isProtected"];
    [c encodeBool:self.isVerified forKey:@"isVerified"];
    [c encodeBool:self.isFollowing forKey:@"isFollowing"];
    [c encodeObject:self.favoritesCount forKey:@"favoritesCount"];
    [c encodeObject:self.followersCount forKey:@"followersCount"];
    [c encodeObject:self.followingCount forKey:@"followingCount"];
    [c encodeObject:self.tweetCount forKey:@"tweetCount"];
    [c encodeObject:self.profileBackgroundImageUrl forKey:@"profileBackgroundImageUrl"];
    [c encodeObject:self.profilePicUrl_mini forKey:@"profilePicUrl_mini"];
    [c encodeObject:self.profilePicUrl_normal forKey:@"profilePicUrl_normal"];
    [c encodeObject:self.profilePicUrl_bigger forKey:@"profilePicUrl_bigger"];
    [c encodeObject:self.profilePicUrl_original forKey:@"profilePicUrl_original"];
}

- (id)initWithCoder:(NSCoder *)d
{
    self = [super init];
    if (!self) return nil;
    
    self.userID = [d decodeInt64ForKey:@"userID"];
    self.screenName = [d decodeObjectForKey:@"screenName"];
    self.name = [d decodeObjectForKey:@"name"];
    self.bio = [d decodeObjectForKey:@"bio"];
    self.location = [d decodeObjectForKey:@"location"];
    self.isProtected = [d decodeBoolForKey:@"isProtected"];
    self.isVerified = [d decodeBoolForKey:@"isVerified"];
    self.isFollowing = [d decodeBoolForKey:@"isFollowing"];
    self.favoritesCount = [d decodeObjectForKey:@"favoritesCount"];
    self.followersCount = [d decodeObjectForKey:@"followersCount"];
    self.followingCount = [d decodeObjectForKey:@"followingCount"];
    self.tweetCount = [d decodeObjectForKey:@"tweetCount"];
    self.profileBackgroundImageUrl = [d decodeObjectForKey:@"profileBackgroundImageUrl"];
    self.profilePicUrl_mini = [d decodeObjectForKey:@"profilePicUrl_mini"];
    self.profilePicUrl_normal = [d decodeObjectForKey:@"profilePicUrl_normal"];
    self.profilePicUrl_bigger = [d decodeObjectForKey:@"profilePicUrl_bigger"];
    self.profilePicUrl_original = [d decodeObjectForKey:@"profilePicUrl_original"];
    
    return self;
}

@end
