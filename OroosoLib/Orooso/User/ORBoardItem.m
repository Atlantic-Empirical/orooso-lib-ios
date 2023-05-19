//
//  ORBoardItem.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 11/07/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORBoardItem.h"
#import "ORSFItem.h"
#import "ISO8601DateFormatter.h"

@implementation ORBoardItem

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
    self.itemId = [json valueForKey:@"ItemId"];
    self.ownerId = [json valueForKey:@"OwnerId"];
    self.created = [f dateFromString:[json valueForKey:@"Created"]];
    self.item = [ORSFItem instanceWithJSON:[json valueForKey:@"Item"]];
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:4];
    ISO8601DateFormatter *f = [[ISO8601DateFormatter alloc] init];
    
    [d setValue:self.boardId forKey:@"BoardId"];
    [d setValue:self.itemId forKey:@"ItemId"];
    [d setValue:self.ownerId forKey:@"OwnerId"];
    [d setValue:[f stringFromDate:self.created] forKey:@"Created"];
    [d setValue:[self.item proxyForJson] forKey:@"Item"];
    
    return d;
}

- (id)initWithItem:(ORSFItem *)item
{
    self = [super init];
    if (!self) return nil;

    self.item = item;
    self.itemId = item.itemID;
    
    return self;
}

@end
