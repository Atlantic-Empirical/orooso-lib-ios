//
//  ORVimeoUser.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 12/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORVimeoUser.h"

@implementation ORVimeoUser

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

- (id)json:(NSDictionary *)json valueForKey:(NSString *)key
{
    id value = [json valueForKey:key];
    if ([[NSNull null] isEqual:value]) return nil;
    return value;
}

- (id)json:(NSDictionary *)json valueForKeyPath:(NSString *)key
{
    id value = [json valueForKeyPath:key];
    if ([[NSNull null] isEqual:value]) return nil;
    return value;
}

- (id)initWithJSON:(NSDictionary *)json
{
    self = [super init];
    if (!self) return nil;
    if (!json || ![json isKindOfClass:[NSDictionary class]]) return nil;
    
    self.userID = [self json:json valueForKey:@"UserID"];
    self.displayName = [self json:json valueForKey:@"DisplayName"];
    self.isPlus = [[self json:json valueForKey:@"Plus"] boolValue];
    self.isPro = [[self json:json valueForKey:@"Pro"] boolValue];
    self.isStaff = [[self json:json valueForKey:@"Staff"] boolValue];
    self.realName = [self json:json valueForKey:@"RealName"];
    self.userName = [self json:json valueForKey:@"UserName"];
    self.profileURL = [self json:json valueForKey:@"ProfileURL"];
    self.videosURL = [self json:json valueForKey:@"VideosURL"];
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:9];
    
    [d setValue:self.userID forKey:@"UserID"];
    [d setValue:self.displayName forKey:@"DisplayName"];
    [d setValue:@(self.isPlus) forKey:@"Plus"];
    [d setValue:@(self.isPro) forKey:@"Pro"];
    [d setValue:@(self.isStaff) forKey:@"Staff"];
    [d setValue:self.realName forKey:@"RealName"];
    [d setValue:self.userName forKey:@"UserName"];
    [d setValue:self.profileURL forKey:@"ProfileURL"];
    [d setValue:self.videosURL forKey:@"VideosURL"];
    
    return d;
}

+ (id)instanceWithVimeoJSON:(NSDictionary *)json
{
    return [[self alloc] initWithVimeoJSON:json];
}

+ (id)arrayWithVimeoJSON:(NSArray *)json
{
    if (!json || ![json isKindOfClass:[NSArray class]]) return nil;
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:json.count];
    
    for (NSDictionary *dict in json) {
        id item = [self instanceWithVimeoJSON:dict];
        if (item) [items addObject:item];
    }
    
    return items;
}

- (id)initWithVimeoJSON:(NSDictionary *)json
{
    if (!json || ![json isKindOfClass:[NSDictionary class]]) return nil;
    
    self = [super init];
    if (!self) return nil;
    
    self.userID = [self json:json valueForKey:@"id"];
    self.displayName = [self json:json valueForKey:@"display_name"];
    self.isPlus = [[self json:json valueForKey:@"is_plus"] boolValue];
    self.isPro = [[self json:json valueForKey:@"is_pro"] boolValue];
    self.isStaff = [[self json:json valueForKey:@"is_staff"] boolValue];
    self.realName = [self json:json valueForKey:@"realname"];
    self.userName = [self json:json valueForKey:@"username"];
    self.profileURL = [self json:json valueForKey:@"profileurl"];
    self.videosURL = [self json:json valueForKey:@"videosurl"];
    
    return self;
}

@end
