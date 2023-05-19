//
//  ORYouTubeVideo.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 07/09/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "ORYouTubeVideo.h"

@interface ORYouTubeVideo ()

- (void)cleanupNulls;

@end

@implementation ORYouTubeVideo

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
    
    self.queryString = [json valueForKey:@"QueryString"];
    self.source = [json valueForKey:@"Source"];
    self.videoID = [json valueForKey:@"VideoID"];
    self.videoURL = [json valueForKey:@"VideoURL"];
    self.title = [json valueForKey:@"Title"];
    self.videoDescription = [json valueForKey:@"Description"];
    self.author = [json valueForKey:@"Author"];
    self.authorURL = [json valueForKey:@"AuthorURL"];
    self.category = [json valueForKey:@"Category"];
    self.published = [json valueForKey:@"Published"];
    self.duration = [json valueForKey:@"Duration"];
    self.views = [json valueForKey:@"Views"];
    self.favorites = [json valueForKey:@"Favorites"];
    self.likes = [json valueForKey:@"Likes"];
    self.dislikes = [json valueForKey:@"Dislikes"];
    self.thumbnailURL = [json valueForKey:@"ThumbnailURL"];

    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:16];
    
    [d setValue:self.queryString forKey:@"QueryString"];
    [d setValue:self.source forKey:@"Source"];
    [d setValue:self.videoID forKey:@"VideoID"];
    [d setValue:self.videoURL forKey:@"VideoURL"];
    [d setValue:self.title forKey:@"Title"];
    [d setValue:self.videoDescription forKey:@"Description"];
    [d setValue:self.author forKey:@"Author"];
    [d setValue:self.authorURL forKey:@"AuthorURL"];
    [d setValue:self.category forKey:@"Category"];
    [d setValue:self.published forKey:@"Published"];
    [d setValue:self.duration forKey:@"Duration"];
    [d setValue:self.views forKey:@"Views"];
    [d setValue:self.favorites forKey:@"Favorites"];
    [d setValue:self.likes forKey:@"Likes"];
    [d setValue:self.dislikes forKey:@"Dislikes"];
    [d setValue:self.thumbnailURL forKey:@"ThumbnailURL"];
    
    return d;
}

#pragma mark - Initialization

- (id)initWithYTJSON:(NSDictionary *)jsonData
{
    self = [super init];
    if (self) [self parseYTJSON:jsonData];
    return self;
}

- (void)parseYTJSON:(NSDictionary *)jsonData
{
    self.videoID = [[[jsonData objectForKey:@"media$group"] objectForKey:@"yt$videoid"] objectForKey:@"$t"];
    self.videoURL = [[[jsonData objectForKey:@"media$group"] objectForKey:@"media$player"] objectForKey:@"url"];
    self.title = [[jsonData objectForKey:@"title"] objectForKey:@"$t"];
    self.videoDescription = [[[jsonData objectForKey:@"media$group"] objectForKey:@"media$description"] objectForKey:@"$t"];
    self.author = [[[[jsonData objectForKey:@"author"] objectAtIndex:0] objectForKey:@"name"] objectForKey:@"$t"];
    self.authorURL = [[[[jsonData objectForKey:@"author"] objectAtIndex:0] objectForKey:@"uri"] objectForKey:@"$t"];
    self.category = [[[[jsonData objectForKey:@"media$group"] objectForKey:@"media$category"] objectAtIndex:0] objectForKey:@"$t"];
    self.thumbnailURL = [[[[jsonData objectForKey:@"media$group"] objectForKey:@"media$thumbnail"] objectAtIndex:0] objectForKey:@"url"];
    self.duration = [[[jsonData objectForKey:@"media$group"] objectForKey:@"yt$duration"] objectForKey:@"seconds"];
    self.views = [[jsonData objectForKey:@"yt$statistics"] objectForKey:@"viewCount"];
    self.favorites = [[jsonData objectForKey:@"yt$statistics"] objectForKey:@"favoriteCount"];
    self.likes = [[jsonData objectForKey:@"yt$rating"] objectForKey:@"numLikes"];
    self.dislikes = [[jsonData objectForKey:@"yt$rating"] objectForKey:@"numDislikes"];
	self.published = [[jsonData objectForKey:@"published"] objectForKey:@"$t"];
    
    NSString *tmp = [jsonData valueForKeyPath:@"app$control.yt$state.name"];
    self.isMobileRestricted = (tmp && [tmp isKindOfClass:[NSString class]] && [tmp isEqualToString:@"restricted"]);
    
    [self cleanupNulls];
}

#pragma mark - Custom Methods

- (void)cleanupNulls
{
    if ([self.videoID class] == [NSNull class]) self.videoID = nil;
    if ([self.videoURL class] == [NSNull class]) self.videoURL = nil;
    if ([self.title class] == [NSNull class]) self.title = nil;
    if ([self.videoDescription class] == [NSNull class]) self.videoDescription = nil;
    if ([self.author class] == [NSNull class]) self.author = nil;
    if ([self.authorURL class] == [NSNull class]) self.authorURL = nil;
    if ([self.category class] == [NSNull class]) self.category = nil;
    if ([self.thumbnailURL class] == [NSNull class]) self.thumbnailURL = nil;
    if ([self.published class] == [NSNull class]) self.published = nil;
    if ([self.duration class] == [NSNull class]) self.duration = nil;
    if ([self.views class] == [NSNull class]) self.views = nil;
    if ([self.favorites class] == [NSNull class]) self.favorites = nil;
    if ([self.likes class] == [NSNull class]) self.likes = nil;
    if ([self.dislikes class] == [NSNull class]) self.dislikes = nil;
}

//================================================================================================================
//
//  THUMBNAILS
//
//================================================================================================================
#pragma mark - THUMBNAILS

//The first one in the list is a full size image and others are thumbnail images. The default thumbnail image (ie. one of 1.jpg, 2.jpg, 3.jpg) is:
//http://img.youtube.com/vi/<insert-youtube-video-id-here>/default.jpg

//For the high quality version of the thumbnail use a url similar to this:
//http://img.youtube.com/vi/<insert-youtube-video-id-here>/hqdefault.jpg
// seems to be 480x360

//There is also a medium quality version of the thumbnail, using a url similar to the HQ:
//http://img.youtube.com/vi/<insert-youtube-video-id-here>/mqdefault.jpg

//For the maximum resolution version of the thumbnail use a url similar to this:
//http://img.youtube.com/vi/<insert-youtube-video-id-here>/maxresdefault.jpg

- (NSString*)thumbnailURL_hqdefault{
	return [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/hqdefault.jpg", self.videoID];
}

- (NSString*)thumbnailURL_maxres{
	return [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/maxresdefault.jpg", self.videoID];
}

+ (NSString*)thumbnailURLHqDefaultForVideoID:(NSString*)videoID{
	return [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/hqdefault.jpg", videoID];
}

- (NSString*)urlShort{
	return [NSString stringWithFormat:@"http://youtu.be/%@", self.videoID];
}

@end
