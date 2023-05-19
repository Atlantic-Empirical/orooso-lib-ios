//
//  OREmailType.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 15/08/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "OREmailType.h"

@implementation OREmailType

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
	
    self.emailType = [json valueForKey:@"EmailType"];
    self.title = [json valueForKey:@"Title"];
    self.userDescription = [json valueForKey:@"UserDescription"];
    self.isSelected = YES;
	
	return self;
}

- (NSMutableDictionary *)proxyForJson
{
	NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:4];
    
    [json setValue:self.emailType forKey:@"EmailType"];
    [json setValue:self.title forKey:@"Title"];
    [json setValue:self.userDescription forKey:@"UserDescription"];
    
	return json;
}

@end
