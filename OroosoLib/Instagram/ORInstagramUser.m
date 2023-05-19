//
//  ORIGUser.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 10/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORInstagramUser.h"

@implementation ORInstagramUser

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
    
    self.userID = [json valueForKey:@"UserID"];
    self.username = [json valueForKey:@"Username"];
    self.fullName = [json valueForKey:@"FullName"];
    self.bio = [json valueForKey:@"Bio"];
    self.profilePicture = [json valueForKey:@"ProfilePicture"];
    self.website = [json valueForKey:@"Website"];
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:6];
    
    [d setValue:self.userID forKey:@"UserID"];
    [d setValue:self.username forKey:@"Username"];
    [d setValue:self.fullName forKey:@"FullName"];
    [d setValue:self.bio forKey:@"Bio"];
    [d setValue:self.profilePicture forKey:@"ProfilePicture"];
    [d setValue:self.website forKey:@"Website"];
    
    return d;
}

+ (id)instanceWithIGJSON:(NSDictionary *)json
{
    return [[ORInstagramUser alloc] initWithIGJSON:json];
}

- (id)initWithIGJSON:(NSDictionary *)json
{
    if (!json || ![json isKindOfClass:[NSDictionary class]]) return nil;
    
    self = [super init];
    if (!self) return nil;
    
    self.userID = [json valueForKey:@"id"];
    self.username = [json valueForKey:@"username"];
    self.fullName = [json valueForKey:@"full_name"];
    self.bio = [json valueForKey:@"bio"];
    self.profilePicture = [json valueForKey:@"profile_picture"];
    self.website = [json valueForKey:@"website"];

    return self;
}

@end
