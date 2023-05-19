//
//  ORSKEvent.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 11/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSongkickEvent.h"
#import "ORSongkickPerformance.h"

@implementation ORSongkickEvent

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
    
    self.eventId = [json valueForKey:@"EventId"];
    self.displayName = [json valueForKey:@"DisplayName"];
    self.type = [json valueForKey:@"Type"];
    self.eventURL = [json valueForKey:@"EventURL"];
    self.city = [json valueForKey:@"City"];
    self.latitude = [[json valueForKey:@"Latitude"] doubleValue];
    self.longitude = [[json valueForKey:@"Longitude"] doubleValue];
    self.venueName = [json valueForKey:@"VenueName"];
    self.venueId = [json valueForKey:@"VenueId"];
    self.date = [json valueForKey:@"Date"];
    self.performances = [ORSongkickPerformance arrayWithJSON:[json valueForKey:@"Performances"]];
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:11];
    
    [d setValue:self.eventId forKey:@"EventId"];
    [d setValue:self.displayName forKey:@"DisplayName"];
    [d setValue:self.type forKey:@"Type"];
    [d setValue:self.eventURL forKey:@"EventURL"];
    [d setValue:self.city forKey:@"City"];
    [d setValue:@(self.latitude) forKey:@"Latitude"];
    [d setValue:@(self.longitude) forKey:@"Longitude"];
    [d setValue:self.venueName forKey:@"VenueName"];
    [d setValue:self.venueId forKey:@"VenueId"];
    [d setValue:self.date forKey:@"Date"];
    [d setValue:[ORSongkickPerformance proxyForJsonWithArray:self.performances] forKey:@"Performances"];
    
    return d;
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
    
    self.eventId = [json valueForKey:@"id"];
    self.displayName = [json valueForKey:@"displayName"];
    self.type = [json valueForKey:@"type"];
    self.eventURL = [json valueForKey:@"uri"];
    
    if ([json valueForKey:@"location"]) {
        self.city = [json valueForKeyPath:@"location.city"];
        self.latitude = [[json valueForKeyPath:@"location.lat"] doubleValue];
        self.longitude = [[json valueForKeyPath:@"location.lng"] doubleValue];
    }

    if ([json valueForKey:@"venue"]) {
        self.venueId = [json valueForKeyPath:@"venue.id"];
        self.venueName = [json valueForKeyPath:@"venue.displayName"];
    }

    self.date = [json valueForKeyPath:@"start.datetime"];
    if (!self.date) self.date = [json valueForKeyPath:@"start.date"];
    
    self.performances = [ORSongkickPerformance arrayWithSKJSON:[json valueForKey:@"performance"]];
    
    return self;
}

- (ORSongkickPerformance*)performance0
{
	if (!self.performances || self.performances.count == 0) return nil;
	return [self.performances objectAtIndex:0];
}

@end
