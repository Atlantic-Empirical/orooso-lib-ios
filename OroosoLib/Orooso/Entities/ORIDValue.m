//
//  ORIDValue.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 17/09/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORIDValue.h"

@implementation ORIDValue

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

+ (NSArray *)proxyForJsonWithArray:(NSArray *)items
{
    if (!items) return nil;
    
    NSMutableArray *a = [NSMutableArray arrayWithCapacity:items.count];
    
    for (ORIDValue *item in items) {
        NSDictionary *i = [item proxyForJson];
        if (i) [a addObject:i];
    }
    
    return a;
}

- (id)initWithJSON:(NSDictionary *)json
{
    self = [super init];
    if (!self) return nil;
    if (!json || ![json isKindOfClass:[NSDictionary class]]) return nil;
    
    self.id = [json valueForKey:@"ID"];
    self.value = [json valueForKey:@"Value"];
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [d setValue:self.id forKey:@"ID"];
    [d setValue:self.value forKey:@"Value"];
    
    return d;
}

@end
