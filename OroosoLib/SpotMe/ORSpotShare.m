//
//  ORSpotShare.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 02/09/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSpotShare.h"
#import "ISO8601DateFormatter.h"

@implementation ORSpotShare

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
    
    ISO8601DateFormatter *f = [[ISO8601DateFormatter alloc] init];
	
    self.spotShareID = [json valueForKey:@"SpotShareID"];
    self.fromName = [json valueForKey:@"FromName"];
    self.fromEmail = [json valueForKey:@"FromEmail"];
    self.toName = [json valueForKey:@"ToName"];
    self.toEmail = [json valueForKey:@"ToEmail"];
    self.message = [json valueForKey:@"Message"];
    self.created = [f dateFromString:[json valueForKey:@"Created"]];
    self.expire = [[json valueForKey:@"Expire"] unsignedIntegerValue];
    self.position = CLLocationCoordinate2DMake([[json valueForKey:@"Latitude"] doubleValue], [[json valueForKey:@"Longitude"] doubleValue]);
	
	return self;
}

- (NSMutableDictionary *)proxyForJson
{
	NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:9];
    
    [json setValue:self.spotShareID forKey:@"SpotShareID"];
    [json setValue:self.fromName forKey:@"FromName"];
    [json setValue:self.fromEmail forKey:@"FromEmail"];
    [json setValue:self.toName forKey:@"ToName"];
    [json setValue:self.toEmail forKey:@"ToEmail"];
    [json setValue:self.message forKey:@"Message"];
    [json setValue:@(self.expire) forKey:@"Expire"];
    [json setValue:@(self.position.latitude) forKey:@"Latitude"];
    [json setValue:@(self.position.longitude) forKey:@"Longitude"];
    
	return json;
}

- (BOOL)isExpired
{
    if (!self.created) return YES;
    
    NSDate *expireDate = [self.created dateByAddingTimeInterval:self.expire * 60.0f];
    if (!expireDate || [expireDate compare:[NSDate date]] == NSOrderedAscending) return YES;
    
    return NO;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)c
{
    [c encodeObject:self.spotShareID forKey:@"SpotShareID"];
    [c encodeObject:self.fromName forKey:@"FromName"];
    [c encodeObject:self.fromEmail forKey:@"FromEmail"];
    [c encodeObject:self.toName forKey:@"ToName"];
    [c encodeObject:self.toEmail forKey:@"ToEmail"];
    [c encodeObject:self.message forKey:@"Message"];
    [c encodeObject:self.created forKey:@"Created"];
    [c encodeInteger:self.expire forKey:@"Expire"];
    [c encodeDouble:self.position.latitude forKey:@"Latitude"];
    [c encodeDouble:self.position.longitude forKey:@"Longitude"];
}

- (id)initWithCoder:(NSCoder *)d
{
    self = [super init];
    if (!self) return nil;
    
    self.spotShareID = [d decodeObjectForKey:@"SpotShareID"];
    self.fromName = [d decodeObjectForKey:@"FromName"];
    self.fromEmail = [d decodeObjectForKey:@"FromEmail"];
    self.toName = [d decodeObjectForKey:@"ToName"];
    self.toEmail = [d decodeObjectForKey:@"ToEmail"];
    self.message = [d decodeObjectForKey:@"Message"];
    self.created = [d decodeObjectForKey:@"Created"];
    self.expire = [d decodeIntegerForKey:@"Expire"];
    
    double lat = [d decodeDoubleForKey:@"Latitude"];
    double lng = [d decodeDoubleForKey:@"Longitude"];
    self.position = CLLocationCoordinate2DMake(lat, lng);
    
    return self;
}

@end
