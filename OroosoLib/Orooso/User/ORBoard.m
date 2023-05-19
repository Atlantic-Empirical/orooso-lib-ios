//
//  ORBoard.m
//  Orooso
//
//  Created by Thomas Purnell-Fisher on 7/30/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "ORBoard.h"
#import "ORFriend.h"
#import "ISO8601DateFormatter.h"

@implementation ORBoard

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
    
    self = [super init];
    if (!self) return nil;
    
    ISO8601DateFormatter *f = [[ISO8601DateFormatter alloc] init];
    
    self.boardId = [json valueForKey:@"BoardId"];
    self.ownerId = [json valueForKey:@"OwnerId"];
    self.name = [json valueForKey:@"Name"];
    self.created = [f dateFromString:[json valueForKey:@"Created"]];
    self.isDefault = [[json valueForKey:@"Default"] boolValue];
    self.isPublic = [[json valueForKey:@"Public"] boolValue];
    self.imageUrl = [json valueForKey:@"ImageUrl"];
    self.owner = [ORFriend instanceWithJSON:[json valueForKey:@"Owner"]];
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:7];
    ISO8601DateFormatter *f = [[ISO8601DateFormatter alloc] init];
    
    [d setValue:self.boardId forKey:@"BoardId"];
    [d setValue:self.ownerId forKey:@"OwnerId"];
    [d setValue:self.name forKey:@"Name"];
    [d setValue:[f stringFromDate:self.created] forKey:@"Created"];
    [d setValue:@(self.isDefault) forKey:@"Default"];
    [d setValue:@(self.isPublic) forKey:@"Public"];
    [d setValue:self.imageUrl forKey:@"ImageUrl"];
    
    return d;
}

- (NSUInteger)hash
{
    return [self.boardId hash];
}

- (BOOL)isEqual:(id)object
{
    if (self == object) return YES;
    if (!self.boardId) return NO;
    if (![object isKindOfClass:[self class]]) return NO;
    
    return [self.boardId isEqual:[object boardId]];
}

@end
