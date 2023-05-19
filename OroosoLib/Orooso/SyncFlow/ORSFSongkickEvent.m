//
//  ORSFSKEvent.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 11/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFSongkickEvent.h"
#import "ORSongkickEvent.h"
#import "OREntity.h"
#import "ORURL.h"

@implementation ORSFSongkickEvent

- (id)initWithJSON:(NSDictionary *)json
{
    self = [super initWithJSON:json];
    if (!self) return nil;
    
    self.event = [ORSongkickEvent instanceWithJSON:[json valueForKey:@"Event"]];
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [super proxyForJson];
    
    [d setValue:[self.event proxyForJson] forKey:@"Event"];
    
    return d;
}

- (id)initWithSKEvent:(ORSongkickEvent *)event andEntity:(OREntity *)entity
{
    self = [super init];
    
    if (self) {
        self.type = SFItemTypeSongkickEvent;
        self.itemID = event.eventId;
        self.title = event.displayName;
        self.avatarURL = [NSURL URLWithString:@"http://s3.amazonaws.com/portl-static/songkick-pink-50x.png"];
        self.detailURL = [ORURL URLWithURLString:event.eventURL];
		self.parentEntity = entity;
        self.event = event;
    }
    
    return self;
}

- (void)setRawScores
{
    
}

@end
