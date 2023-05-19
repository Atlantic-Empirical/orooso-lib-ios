//
//  ORIGImage.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 10/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORInstagramImage.h"
#import "ORInstagramUser.h"

@implementation ORInstagramImage

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
    
    self.imageID = [json valueForKey:@"ImageID"];
    self.attribution = [json valueForKey:@"Attribution"];
    self.captionCreatedTime = [json valueForKey:@"CaptionCreatedTime"];
    self.captionAuthor = [ORInstagramUser instanceWithJSON:[json valueForKey:@"CaptionAuthor"]];
    self.captionID = [json valueForKey:@"CaptionID"];
    self.captionText = [json valueForKey:@"CaptionText"];
    self.commentCount = [[json valueForKey:@"CommentCount"] integerValue];
    self.likeCount = [[json valueForKey:@"LikeCount"] integerValue];
    self.createdTime = [json valueForKey:@"CreatedTime"];
    self.filter = [json valueForKey:@"Filter"];
    self.link = [json valueForKey:@"Link"];
    self.tags = [json valueForKey:@"Tags"];
    self.type = [json valueForKey:@"Type"];
    self.user = [ORInstagramUser instanceWithJSON:[json valueForKey:@"User"]];
    self.latitude = [[json valueForKey:@"Latitude"] doubleValue];
    self.longitude = [[json valueForKey:@"Longitude"] doubleValue];
    self.imageStandard = [json valueForKey:@"ImageStandard"];
    self.imageLow = [json valueForKey:@"ImageLow"];
    self.imageThumbnail = [json valueForKey:@"ImageThumbnail"];
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:19];
    
    [d setValue:self.imageID forKey:@"ImageID"];
    [d setValue:self.attribution forKey:@"Attribution"];
    [d setValue:self.captionCreatedTime forKey:@"CaptionCreatedTime"];
    [d setValue:[self.captionAuthor proxyForJson] forKey:@"CaptionAuthor"];
    [d setValue:self.captionID forKey:@"CaptionID"];
    [d setValue:self.captionText forKey:@"CaptionText"];
    [d setValue:@(self.commentCount) forKey:@"CommentCount"];
    [d setValue:@(self.likeCount) forKey:@"LikeCount"];
    [d setValue:self.createdTime forKey:@"CreatedTime"];
    [d setValue:self.filter forKey:@"Filter"];
    [d setValue:self.link forKey:@"Link"];
    [d setValue:self.tags forKey:@"Tags"];
    [d setValue:self.type forKey:@"Type"];
    [d setValue:[self.user proxyForJson] forKey:@"User"];
    [d setValue:@(self.latitude) forKey:@"Latitude"];
    [d setValue:@(self.longitude) forKey:@"Longitude"];
    [d setValue:self.imageStandard forKey:@"ImageStandard"];
    [d setValue:self.imageLow forKey:@"ImageLow"];
    [d setValue:self.imageThumbnail forKey:@"ImageThumbnail"];
    
    return d;
}

+ (id)instanceWithIGJSON:(NSDictionary *)json
{
    return [[self alloc] initWithIGJSON:json];
}

+ (id)arrayWithIGJSON:(NSArray *)json
{
    if (!json || ![json isKindOfClass:[NSArray class]]) return nil;
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:json.count];
    
    for (NSDictionary *dict in json) {
        id item = [self instanceWithIGJSON:dict];
        if (item) [items addObject:item];
    }
    
    return items;
}

- (id)initWithIGJSON:(NSDictionary *)json
{
    if (!json || ![json isKindOfClass:[NSDictionary class]]) return nil;
    
    self = [super init];
    if (!self) return nil;
    
    self.imageID = [json valueForKey:@"id"];
    self.type = [json valueForKey:@"type"];
    self.filter = [json valueForKey:@"filter"];
    self.link = [json valueForKey:@"link"];
    self.user = [ORInstagramUser instanceWithIGJSON:[json valueForKey:@"user"]];
    self.createdTime = [json valueForKey:@"created_time"];
    
    self.likeCount = [[json valueForKeyPath:@"likes.count"] intValue];
    self.commentCount = [[json valueForKeyPath:@"comments.count"] intValue];
    
    self.imageStandard = [json valueForKeyPath:@"images.standard_resolution.url"];
    self.imageLow = [json valueForKeyPath:@"images.low_resolution.url"];
    self.imageThumbnail = [json valueForKeyPath:@"images.thumbnail.url"];
    
    if ([json valueForKey:@"caption"]) {
        self.captionAuthor = [ORInstagramUser instanceWithIGJSON:[json valueForKeyPath:@"caption.from"]];
        self.captionCreatedTime = [json valueForKeyPath:@"caption.created_time"];
        self.captionText = [json valueForKeyPath:@"caption.text"];
        self.captionID = [json valueForKeyPath:@"caption.id"];
    }
    
    if ([json valueForKey:@"tags"] && [[json valueForKey:@"tags"] isKindOfClass:[NSArray class]]) {
        self.tags = [json valueForKey:@"tags"];
    }
    
    return self;
}

@end
