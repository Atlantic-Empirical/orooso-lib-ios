//
//  ORInstantResult.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 01/02/2013.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORInstantResult.h"

@implementation ORInstantResult

#pragma mark - Class Methods

+ (id)instanceWithJSON:(NSDictionary *)json
{
    return [[self alloc] initWithJSON:json];
}

+ (id)instanceWithFreebaseJSON:(NSDictionary *)json
{
    return [[self alloc] initWithFreebaseJSON:json];
}

+ (id)instanceWithEntity:(OREntity *)entity
{
    return [[self alloc] initWithEntity:entity];
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

+ (id)arrayWithFreebaseJSON:(NSArray *)json
{
    if (!json || ![json isKindOfClass:[NSArray class]]) return nil;
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:json.count];
    
    for (NSDictionary *dict in json) {
        id item = [self instanceWithFreebaseJSON:dict];
        if (item) [items addObject:item];
    }
    
    return items;
}

#pragma mark - Initialization

- (id)initWithJSON:(NSDictionary *)json
{
    if (!json || ![json isKindOfClass:[NSDictionary class]]) return nil;

    self = [super init];
    if (!self) return nil;

    self.type = [[json valueForKey:@"Type"] integerValue];
    self.entityId = [json valueForKey:@"Id"];
    self.freebaseID = [json valueForKey:@"FreebaseID"];
    self.name = [json valueForKey:@"Name"];
    self.imageURL = [json valueForKey:@"ImageURL"];
    self.cardImageURL = self.imageURL;
    self.popularity = [[json valueForKey:@"Popularity"] unsignedIntegerValue];
    self.wikipediaPageId = [json valueForKey:@"WikipediaPageId"];
    self.entityDescription = [json valueForKey:@"Description"];
    self.pinCount = [[json valueForKey:@"PinCount"] intValue];
    self.typeName = [OREntity nameForType:self.type];
    self.source = [json valueForKey:@"Source"];
    if (self.pinCount < 0) self.pinCount = 0;
    
    return self;
}

- (id)initWithFreebaseJSON:(NSDictionary *)json
{
    if (!json || ![json isKindOfClass:[NSDictionary class]]) return nil;
    
	self = [self init];
    if (!self) return nil;

    self.entityId = nil;
    self.freebaseID = [json valueForKey:@"mid"];
    self.name = [json valueForKey:@"name"];
    self.typeName = [json valueForKeyPath:@"notable.name"];
    self.popularity = [[json valueForKey:@"score"] integerValue];
    
    if (!self.typeName) return nil;
    if ([self.name isEqualToString:@""]) return nil;
    
	return self;
}

- (id)initWithEntity:(OREntity *)entity
{
    self = [super init];
    if (!self) return nil;
    
    self.type = entity.entityType;
    self.entityId = entity.entityId;
    self.freebaseID = entity.freebaseID;
    self.name = entity.name;
    self.imageURL = entity.urlRepresentativeImage;
    self.cardImageURL = entity.urlRepresentativeImage;
    self.wikipediaPageId = entity.wikipediaPageId;
    self.isDynamic = entity.isDynamic;
    self.entityDescription = entity.entityDescription;
    
    return self;
}

#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)d
{
    self = [self init];
    
    if (self) {
        self.type = [d decodeIntegerForKey:@"Type"];
        self.entityId = [d decodeObjectForKey:@"Id"];
        self.freebaseID = [d decodeObjectForKey:@"FreebaseID"];
        self.name = [d decodeObjectForKey:@"Name"];
        self.imageURL = [d decodeObjectForKey:@"ImageURL"];
        self.popularity = [d decodeIntegerForKey:@"Popularity"];
        self.wikipediaPageId = [d decodeObjectForKey:@"WikipediaPageId"];
        self.entityDescription = [d decodeObjectForKey:@"Description"];
        self.cardImageURL = self.imageURL;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)c
{
    [c encodeInteger:self.type forKey:@"Type"];
    [c encodeObject:self.entityId forKey:@"Id"];
    [c encodeObject:self.freebaseID forKey:@"FreebaseID"];
    [c encodeObject:self.name forKey:@"Name"];
    [c encodeObject:self.imageURL forKey:@"ImageURL"];
    [c encodeInteger:self.popularity forKey:@"Popularity"];
    [c encodeInteger:self.wikipediaPageId forKey:@"WikipediaPageId"];
    [c encodeObject:self.entityDescription forKey:@"Description"];
}

#pragma mark - Helper Methods

- (NSString*)urlEntityLinkWithSource:(NSString *)source
{
    NSString *url = nil;
	if (self.isDynamic)
		url = [NSString stringWithFormat:@"http://portl.it/d/%@", [self.name or_urlPathEncodedString]];
	else
		url = [NSString stringWithFormat:@"http://portl.it/e/%@/%d", self.entityId, self.type];
    
    return (source) ? [NSString stringWithFormat:@"%@?src=%@", url, source] : url;
}

- (void)setCardImageURL:(NSString *)cardImageURL
{
    if (cardImageURL == _cardImageURL) return;
    
    if ([cardImageURL rangeOfString:@"s3.amazonaws.com/orooso/images/entities"].location != NSNotFound) {
        if (![cardImageURL hasSuffix:@"_800.jpg"]) {
            _cardImageURL = [cardImageURL stringByReplacingOccurrencesOfString:@".jpg" withString:@"_800.jpg"];
            return;
        }
    }
    
    _cardImageURL = cardImageURL;
}

- (NSString*)wikipediaUrl
{
	if (!self.wikipediaPageId) return nil;
	return [NSString stringWithFormat:@"http://en.wikipedia.org/wiki?curid=%@", self.wikipediaPageId];
}

- (NSUInteger)hash
{
    return self.isDynamic ? [self.name hash] : self.freebaseID ? [self.freebaseID hash] : [self.entityId hash];
}

- (BOOL)isEqualToInstantResult:(ORInstantResult *)other
{
    if (self.isDynamic != other.isDynamic) return NO;
    if (!self.freebaseID && other.freebaseID) return NO;
    
    if (self.freebaseID) {
        return [self.freebaseID isEqualToString:other.freebaseID];
    } else {
        if (self.isDynamic) return ([self.name caseInsensitiveCompare:other.name] == NSOrderedSame);
        return [self.entityId isEqualToString:other.entityId];
    }
}

- (BOOL)isEqual:(id)object
{
    if (self == object) return YES;
    if (![object isKindOfClass:[self class]]) return NO;
    
    return [self isEqualToInstantResult:object];
}

@end
