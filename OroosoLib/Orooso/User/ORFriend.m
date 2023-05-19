//
//  ORFriend.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 22/07/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORFriend.h"

@implementation ORFriend

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
    if (!json || ![json isKindOfClass:[NSDictionary class]]) return nil;
    
	self = [self init];
    if (!self) return nil;
	
    self.userId = [json valueForKey:@"UserId"];
    self.emailAddress = [json valueForKey:@"EmailAddress"];
    self.name = [json valueForKey:@"Name"];
    self.matchedHash = [json valueForKey:@"MatchedHash"];
    self.profileImageUrl = [json valueForKey:@"ProfileImageUrl"];
	
	return self;
}

- (NSMutableDictionary *)proxyForJson
{
	NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:4];
    
    [json setValue:self.userId forKey:@"UserId"];
    [json setValue:self.emailAddress forKey:@"EmailAddress"];
    [json setValue:self.name forKey:@"Name"];
    [json setValue:self.matchedHash forKey:@"MatchedHash"];
    [json setValue:self.profileImageUrl forKey:@"ProfileImageUrl"];
    
	return json;
}

- (void)updateWithUser:(ORFriend *)user isFollowing:(BOOL)following isFollower:(BOOL)follower
{
    self.emailAddress = user.emailAddress;
    self.name = user.name;
    self.profileImageUrl = user.profileImageUrl;
    if (following) self.isFollowing = YES;
    if (follower) self.isFollower = YES;
}

- (NSUInteger)hash
{
    return [self.userId hash];
}

- (BOOL)isEqual:(id)object
{
    if (self == object) return YES;
    if (!self.userId) return NO;
    if (![object isKindOfClass:[self class]]) return NO;
    
    return [self.userId isEqual:[object userId]];
}

@end
