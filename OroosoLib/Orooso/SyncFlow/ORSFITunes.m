//
//  ORSFITunesGeneric.m
//  OroosoLib
//
//  Created by Thomas Purnell-Fisher on 3/26/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFITunes.h"
#import "ORITunesObject.h"

@implementation ORSFITunes

- (id)initWithJSON:(NSDictionary *)json
{
    self = [super initWithJSON:json];
    if (!self) return nil;
    
    self.itunesObject = [ORITunesObject instanceWithJSON:[json valueForKey:@"InnerObject"]];
    if ([self.itunesObject.wrapperType isEqualToString:@"artist"]) return nil;
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [super proxyForJson];
    
    [d setValue:[self.itunesObject proxyForJson] forKey:@"InnerObject"];
    
    return d;
}

- (ORSFITunes*)initWithITunesObject:(ORITunesObject *)itObject andEntity:(OREntity *)entity
{
	self = [super initWithEntity:entity itemID:nil];
    
	if (self) {
		self.itunesObject = itObject;
		self.parentEntity = entity;
	}
    
	return self;
}

- (void)setRawScores
{
    // Just to prevent the repeating NSLog
}

@end
