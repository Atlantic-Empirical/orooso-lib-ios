//
//  ORRedditLink.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 27/09/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORRedditLink.h"

@implementation ORRedditLink

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
    if (![[json valueForKey:@"kind"] isEqualToString:@"t3"]) return nil;

    self = [super init];
    if (!self) return nil;
    
    self.kind = [json valueForKey:@"kind"];
    self.domain = [json valueForKeyPath:@"data.domain"];
    self.title = [json valueForKeyPath:@"data.title"];
    self.text = [json valueForKeyPath:@"data.selftext"];
    self.name = [json valueForKeyPath:@"data.name"];
    self.author = [json valueForKeyPath:@"data.author"];
    self.thumbnail = [json valueForKeyPath:@"data.thumbnail"];
    self.permalink = [json valueForKeyPath:@"data.permalink"];
    self.url = [json valueForKeyPath:@"data.url"];
    self.score = [[json valueForKeyPath:@"data.score"] unsignedIntegerValue];
    self.ups = [[json valueForKeyPath:@"data.ups"] unsignedIntegerValue];
    self.downs = [[json valueForKeyPath:@"data.downs"] unsignedIntegerValue];
    self.comments = [[json valueForKeyPath:@"data.num_comments"] unsignedIntegerValue];
    self.created = [[json valueForKeyPath:@"data.created_utc"] unsignedIntegerValue];
    self.isSelf = [[json valueForKeyPath:@"data.is_self"] boolValue];
    self.isOver18 = [[json valueForKeyPath:@"data.over_18"] boolValue];
    
    if ([json valueForKeyPath:@"data.media"] && [json valueForKeyPath:@"data.media"] != [NSNull null]) {
        self.mediaType = [json valueForKeyPath:@"data.media.type"];
        self.mediaThumbnail = [json valueForKeyPath:@"data.media.oembed.thumbnail_url"];
    }
    
    return self;
}

- (NSString *)permalinkUrl
{
    if ([self.permalink hasPrefix:@"http://"] || [self.permalink hasPrefix:@"https://"]) {
        return self.permalink;
    } else {
        return [NSString stringWithFormat:@"http://reddit.com%@", self.permalink];
    }
}

@end
