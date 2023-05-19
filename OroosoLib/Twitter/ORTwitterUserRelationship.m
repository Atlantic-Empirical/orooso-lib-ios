//
//  ORTwitterUserRelationships.m
//  OroosoLib
//
//  Created by Thomas Purnell-Fisher on 2/7/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORTwitterUserRelationship.h"

@implementation ORTwitterUserRelationship

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
    
    self.name = [json valueForKey:@"Name"];
    self.userId = [[json valueForKey:@"UserID"] unsignedLongLongValue];
    self.screenName = [json valueForKey:@"ScreenName"];
    self.isFollowing = [[json valueForKey:@"Following"] boolValue];
    self.isFollowedBy = [[json valueForKey:@"FollowedBy"] boolValue];
    self.followingRequested = [[json valueForKey:@"FollowingRequested"] boolValue];
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:6];
    
    [d setValue:self.name forKey:@"Name"];
    [d setValue:@(self.userId) forKey:@"UserID"];
    [d setValue:self.screenName forKey:@"ScreenName"];
    [d setValue:@(self.isFollowing) forKey:@"Following"];
    [d setValue:@(self.isFollowedBy) forKey:@"FollowedBy"];
    [d setValue:@(self.followingRequested) forKey:@"FollowingRequested"];
    
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
	DLog(@"%@", [jsonData description]);
    self.name = [jsonData objectForKey:@"name"];
    self.userId = [[jsonData objectForKey:@"id"] unsignedLongLongValue];;
    self.screenName = [jsonData objectForKey:@"screen_name"];
    
    if ([[jsonData objectForKey:@"connections"] isKindOfClass:[NSArray class]]) {
        for (NSString *item in [jsonData objectForKey:@"connections"]) {
			if ([item isEqualToString:@"following"])
				self.isFollowing = YES;
			if ([item isEqualToString:@"followed_by"])
				self.isFollowedBy = YES;
			if ([item isEqualToString:@"following_requested"])
				self.followingRequested = YES;
        }
    }
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)c
{
    [c encodeObject:self.name forKey:@"name"];
    [c encodeInt64:self.userId forKey:@"userId"];
    [c encodeObject:self.screenName forKey:@"screenName"];
    [c encodeBool:self.isFollowing forKey:@"isFollowing"];
    [c encodeBool:self.isFollowedBy forKey:@"isFollowedBy"];
    [c encodeBool:self.followingRequested forKey:@"followingRequested"];
}

- (id)initWithCoder:(NSCoder *)d
{
    self = [super init];
    if (!self) return nil;
    
    self.name = [d decodeObjectForKey:@"name"];
    self.userId = [d decodeInt64ForKey:@"userId"];
    self.screenName = [d decodeObjectForKey:@"screenName"];
    self.isFollowing = [d decodeBoolForKey:@"isFollowing"];
    self.isFollowedBy = [d decodeBoolForKey:@"isFollowedBy"];
    self.followingRequested = [d decodeBoolForKey:@"followingRequested"];
    
    return self;
}

@end
