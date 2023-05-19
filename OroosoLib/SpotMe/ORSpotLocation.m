//
//  ORSpotLocation.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 04/09/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSpotLocation.h"

@implementation ORSpotLocation

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
	
    self.spotShareID = [json valueForKey:@"ID"];
    self.position = CLLocationCoordinate2DMake([[json valueForKey:@"La"] doubleValue], [[json valueForKey:@"Lo"] doubleValue]);
	
	return self;
}

- (NSDictionary *)proxyForJson
{
    NSDictionary *dict = @{@"IDs": self.spotShareIDs,
                           @"La": @(self.position.latitude),
                           @"Lo": @(self.position.longitude)};
    return dict;
}

@end
