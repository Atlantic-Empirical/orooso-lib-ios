//
//  ORLogItem.m
//  Orooso
//
//  Created by Thomas Purnell-Fisher on 8/9/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "ORLogItem.h"

@implementation ORLogItem

- (ORLogItem*)initWithTrackId:(NSString*)trackId andUtcSkew:(NSUInteger)utcSkewSeconds
{
	self = [super init];
	if (self) {
		self.trackId = trackId;
		self.timestamp = [NSString stringWithFormat:@"%ld", time(NULL) + utcSkewSeconds];
	}
	return self;
}

- (NSMutableDictionary*) proxyForJson
{
	NSMutableDictionary *md = [[NSMutableDictionary alloc] init];
    
	if (self.trackId) [md setObject:self.trackId forKey:@"TrackId"];
	if (self.timestamp) [md setObject:self.timestamp forKey:@"Timestamp"];
    
    if (self.parameters) {
        NSMutableArray *params = [NSMutableArray arrayWithCapacity:self.parameters.count];
        for (NSString *key in self.parameters) {
            [params addObject:[NSString stringWithFormat:@"%@=%@", key, self.parameters[key]]];
        }
        
        [md setObject:params forKey:@"Parameters"];
    }
    
	return md;
}

@end
