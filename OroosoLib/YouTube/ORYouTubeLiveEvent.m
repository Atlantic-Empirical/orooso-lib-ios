//
//  ORYouTubeLiveEvent.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 11/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORYouTubeLiveEvent.h"

@implementation ORYouTubeLiveEvent

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
    
    self = [super init];
    if (!self) return nil;
    
    self.region = [json valueForKey:@"Region"];
    self.status = [json valueForKey:@"Status"];
    self.videoID = [json valueForKey:@"VideoID"];
    self.videoURL = [json valueForKey:@"VideoURL"];
    self.title = [json valueForKey:@"Title"];
    self.videoDescription = [json valueForKey:@"Description"];
    self.author = [json valueForKey:@"Author"];
    self.authorURL = [json valueForKey:@"AuthorURL"];
    self.category = [json valueForKey:@"Category"];
    self.thumbnailURL = [json valueForKey:@"ThumbnailURL"];
    self.language = [json valueForKey:@"Language"];
    self.start = [json valueForKey:@"Start"];
    self.end = [json valueForKey:@"End"];
    self.published = [json valueForKey:@"Published"];
    self.duration = [[json valueForKey:@"Duration"] unsignedIntegerValue];
    self.views = [[json valueForKey:@"Views"] unsignedIntegerValue];
    self.currentViewers = [[json valueForKey:@"CurrentViewers"] unsignedIntegerValue];
    self.favorites = [[json valueForKey:@"Favorites"] unsignedIntegerValue];
    self.likes = [[json valueForKey:@"Likes"] unsignedIntegerValue];
    self.dislikes = [[json valueForKey:@"Dislikes"] unsignedIntegerValue];
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:20];
    
    [d setValue:self.region forKey:@"Region"];
    [d setValue:self.status forKey:@"Status"];
    [d setValue:self.videoID forKey:@"VideoID"];
    [d setValue:self.videoURL forKey:@"VideoURL"];
    [d setValue:self.title forKey:@"Title"];
    [d setValue:self.videoDescription forKey:@"Description"];
    [d setValue:self.author forKey:@"Author"];
    [d setValue:self.authorURL forKey:@"AuthorURL"];
    [d setValue:self.category forKey:@"Category"];
    [d setValue:self.thumbnailURL forKey:@"ThumbnailURL"];
    [d setValue:self.language forKey:@"Language"];
    [d setValue:self.start forKey:@"Start"];
    [d setValue:self.end forKey:@"End"];
    [d setValue:self.published forKey:@"Published"];
    [d setValue:@(self.duration) forKey:@"Duration"];
    [d setValue:@(self.views) forKey:@"Views"];
    [d setValue:@(self.currentViewers) forKey:@"CurrentViewers"];
    [d setValue:@(self.favorites) forKey:@"Favorites"];
    [d setValue:@(self.likes) forKey:@"Likes"];
    [d setValue:@(self.dislikes) forKey:@"Dislikes"];
    
    
    return d;
}

@end
