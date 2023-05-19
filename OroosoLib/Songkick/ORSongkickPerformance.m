//
//  ORSKPerformance.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 11/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSongkickPerformance.h"

@implementation ORSongkickPerformance

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
    
    self.performanceId = [json valueForKey:@"PerformanceId"];
    self.displayName = [json valueForKey:@"DisplayName"];
    self.billingIndex = [json valueForKey:@"BillingIndex"];
    self.billing = [json valueForKey:@"Billing"];
    self.artistId = [json valueForKey:@"ArtistId"];
    self.artistName = [json valueForKey:@"ArtistName"];
    self.artistURL = [json valueForKey:@"ArtistURL"];
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:7];
    
    [d setValue:self.performanceId forKey:@"PerformanceId"];
    [d setValue:self.displayName forKey:@"DisplayName"];
    [d setValue:self.billingIndex forKey:@"BillingIndex"];
    [d setValue:self.billing forKey:@"Billing"];
    [d setValue:self.artistId forKey:@"ArtistId"];
    [d setValue:self.artistName forKey:@"ArtistName"];
    [d setValue:self.artistURL forKey:@"ArtistURL"];
    
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

+ (id)instanceWithSKJSON:(NSDictionary *)json
{
    return [[self alloc] initWithSKJSON:json];
}

+ (id)arrayWithSKJSON:(NSArray *)json
{
    if (!json || ![json isKindOfClass:[NSArray class]]) return nil;
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:json.count];
    
    for (NSDictionary *dict in json) {
        id item = [self instanceWithSKJSON:dict];
        if (item) [items addObject:item];
    }
    
    return items;
}

- (id)initWithSKJSON:(NSDictionary *)json
{
    if (!json || ![json isKindOfClass:[NSDictionary class]]) return nil;
    
    self = [super init];
    if (!self) return nil;
    
    self.performanceId = [json valueForKey:@"id"];
    self.displayName = [json valueForKey:@"displayName"];
    self.billingIndex = [json valueForKey:@"billingIndex"];
    self.billing = [json valueForKey:@"billing"];
    
    if ([json valueForKey:@"artist"]) {
        self.artistId = [json valueForKeyPath:@"artist.id"];
        self.artistName = [json valueForKeyPath:@"artist.displayName"];
        self.artistURL = [json valueForKeyPath:@"artist.uri"];
    }
    
    return self;
}

@end
