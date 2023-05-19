//
//  ORVimeoVideo.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 12/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORVimeoVideo.h"
#import "ORVimeoUser.h"

@implementation ORVimeoVideo

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

- (id)json:(NSDictionary *)json valueForKey:(NSString *)key
{
    id value = [json valueForKey:key];
    if ([[NSNull null] isEqual:value]) return nil;
    return value;
}

- (id)json:(NSDictionary *)json valueForKeyPath:(NSString *)key
{
    id value = [json valueForKeyPath:key];
    if ([[NSNull null] isEqual:value]) return nil;
    return value;
}

- (id)initWithJSON:(NSDictionary *)json
{
    self = [super init];
    if (!self) return nil;
    if (!json || ![json isKindOfClass:[NSDictionary class]]) return nil;
    
    self.videoID = [self json:json valueForKey:@"VideoID"];
    self.embedPrivacy = [self json:json valueForKey:@"EmbedPrivacy"];
    self.isHD = [[self json:json valueForKey:@"HD"] boolValue];
    self.isLike = [[self json:json valueForKey:@"Like"] boolValue];
    self.isWatchLater = [[self json:json valueForKey:@"WatchLater"] boolValue];
    self.license = [self json:json valueForKey:@"License"];
    self.privacy = [self json:json valueForKey:@"Privacy"];
    self.title = [self json:json valueForKey:@"Title"];
    self.modifiedDate = [self json:json valueForKey:@"ModifiedDate"];
    self.uploadDate = [self json:json valueForKey:@"UploadDate"];
    self.likes = [[self json:json valueForKey:@"Likes"] integerValue];
    self.plays = [[self json:json valueForKey:@"Plays"] integerValue];
    self.comments = [[self json:json valueForKey:@"Comments"] integerValue];
    self.duration = [[self json:json valueForKey:@"Duration"] integerValue];
    self.owner = [ORVimeoUser instanceWithJSON:[self json:json valueForKey:@"Owner"]];
    self.thumbnailURL = [self json:json valueForKey:@"ThumbnailURL"];
    self.videoURL = [self json:json valueForKey:@"VideoURL"];
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:17];
    
    [d setValue:self.videoID forKey:@"VideoID"];
    [d setValue:self.embedPrivacy forKey:@"EmbedPrivacy"];
    [d setValue:@(self.isHD) forKey:@"HD"];
    [d setValue:@(self.isLike) forKey:@"Like"];
    [d setValue:@(self.isWatchLater) forKey:@"WatchLater"];
    [d setValue:self.license forKey:@"License"];
    [d setValue:self.privacy forKey:@"Privacy"];
    [d setValue:self.title forKey:@"Title"];
    [d setValue:self.modifiedDate forKey:@"ModifiedDate"];
    [d setValue:self.uploadDate forKey:@"UploadDate"];
    [d setValue:@(self.likes) forKey:@"Likes"];
    [d setValue:@(self.plays) forKey:@"Plays"];
    [d setValue:@(self.comments) forKey:@"Comments"];
    [d setValue:@(self.duration) forKey:@"Duration"];
    [d setValue:[self.owner proxyForJson] forKey:@"Owner"];
    [d setValue:self.thumbnailURL forKey:@"ThumbnailURL"];
    [d setValue:self.videoURL forKey:@"VideoURL"];
    
    return d;
}

+ (id)instanceWithVimeoJSON:(NSDictionary *)json
{
    return [[self alloc] initWithVimeoJSON:json];
}

+ (id)arrayWithVimeoJSON:(NSArray *)json
{
    if (!json || ![json isKindOfClass:[NSArray class]]) return nil;
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:json.count];
    
    for (NSDictionary *dict in json) {
        id item = [self instanceWithVimeoJSON:dict];
        if (item) [items addObject:item];
    }
    
    return items;
}

- (id)initWithVimeoJSON:(NSDictionary *)json
{
    if (!json || ![json isKindOfClass:[NSDictionary class]]) return nil;
    
    self = [super init];
    if (!self) return nil;

    self.embedPrivacy = [self json:json valueForKey:@"embed_privacy"];
    if (![self.embedPrivacy isKindOfClass:[NSString class]]) return nil;
    if (![self.embedPrivacy isEqualToString:@"anywhere"]) return nil;
    
    self.videoID = [self json:json valueForKey:@"id"];
    self.isHD = [[self json:json valueForKey:@"is_hd"] boolValue];
    self.isLike = [[self json:json valueForKey:@"is_like"] boolValue];
    self.isWatchLater = [[self json:json valueForKey:@"is_watchlater"] boolValue];
    self.license = [self json:json valueForKey:@"license"];
    self.privacy = [self json:json valueForKey:@"privacy"];
    self.title = [self json:json valueForKey:@"title"];
    self.modifiedDate = [self json:json valueForKey:@"modified_date"];
    self.uploadDate = [self json:json valueForKey:@"upload_date"];
    self.likes = [[self json:json valueForKey:@"number_of_likes"] integerValue];
    self.plays = [[self json:json valueForKey:@"number_of_plays"] integerValue];
    self.comments = [[self json:json valueForKey:@"number_of_comments"] integerValue];
    self.duration = [[self json:json valueForKey:@"duration"] integerValue];
    self.owner = [ORVimeoUser instanceWithVimeoJSON:[self json:json valueForKey:@"owner"]];
    self.videoURL = [NSString stringWithFormat:@"http://vimeo.com/%@", self.videoID];
    
    NSUInteger maxWidth = 0;
    for (NSDictionary *dict in [self json:json valueForKeyPath:@"thumbnails.thumbnail"]) {
        NSUInteger width = [[self json:dict valueForKey:@"width"] integerValue];
        if (width > maxWidth) {
            self.thumbnailURL = [self json:dict valueForKey:@"_content"];
            maxWidth = width;
        }
    }
    
    return self;
}

@end
