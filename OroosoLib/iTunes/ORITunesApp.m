//
//  ORITunesApp.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 04/10/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORITunesApp.h"

@implementation ORITunesApp

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
    
    self.appId = [[json valueForKey:@"trackId"] unsignedIntegerValue];
    self.bundleId = [json valueForKey:@"bundleId"];
    self.name = [json valueForKey:@"trackName"];
    self.genre = [json valueForKey:@"primaryGenreName"];
    self.authorUrl = [json valueForKey:@"artistViewUrl"];
    self.artworkUrl = [json valueForKey:@"artworkUrl60"];
    self.authorName = [json valueForKey:@"artistName"];
    self.sellerName = [json valueForKey:@"sellerName"];
    self.version = [json valueForKey:@"version"];
    self.fullDescription = [json valueForKey:@"description"];
    self.currency = [json valueForKey:@"currency"];
    self.releaseDate = [json valueForKey:@"releaseDate"];
    self.releaseNotes = [json valueForKey:@"releaseNotes"];
    self.appViewURL = [json valueForKey:@"trackViewUrl"];
    self.fileSize = [json valueForKey:@"fileSizeBytes"];
    self.price = [[json valueForKey:@"price"] doubleValue];
    
    return self;
}


@end
