//
//  ORTwitterHashtag.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 03/11/2012.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "ORTwitterHashtag.h"

@implementation ORTwitterHashtag

- (NSString *)debugDescription
{
    NSMutableString *desc = [NSMutableString stringWithFormat:
                             @"\t[%@, %@] #%@",
                             self.indices[0], self.indices[1],
                             self.text];
    
    [desc appendString:@"\n"];
    return desc;
}

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
    
    self.text = [json valueForKey:@"Text"];
    self.indices = [json valueForKey:@"Indices"];
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [d setValue:self.text forKey:@"Text"];
    [d setValue:self.indices forKey:@"Indices"];
    
    return d;
}

+ (NSMutableArray *)proxyForJsonWithArray:(NSArray *)array
{
    if (!array) return nil;
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:array.count];
    
    for (id item in array) {
        NSDictionary *d = [item proxyForJson];
        if (d) [items addObject:d];
    }
    
    return items;
}

- (id)initWithTwitterJSON:(NSDictionary *)jsonData
{
    self = [super init];
    if (self) [self parseTwitterJSON:jsonData];
    return self;
}

- (void)parseTwitterJSON:(NSDictionary *)jsonData
{
    self.text = [jsonData objectForKey:@"text"];
    
    self.indices = nil;
    if ([[jsonData objectForKey:@"indices"] isKindOfClass:[NSArray class]]) {
        self.indices = [NSMutableArray arrayWithCapacity:[[jsonData objectForKey:@"indices"] count]];
        
        for (NSNumber *index in [jsonData objectForKey:@"indices"]) {
            [self.indices addObject:index];
        }
    }
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)c
{
    [c encodeObject:self.text forKey:@"text"];
    [c encodeObject:self.indices forKey:@"indices"];
}

- (id)initWithCoder:(NSCoder *)d
{
    self = [super init];
    if (!self) return nil;
    
    self.text = [d decodeObjectForKey:@"text"];
    self.indices = [d decodeObjectForKey:@"indices"];
    
    return self;
}

@end
