//
//  ORTVNZArticle.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 13/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORTVNZArticle.h"

@implementation ORTVNZArticle

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
    
    self.articleId = [json valueForKey:@"Id"];
    self.title = [json valueForKey:@"Title"];
    self.summary = [json valueForKey:@"Description"];
    self.articleURL = [json valueForKey:@"ArticleURL"];
    self.imageURL = [json valueForKey:@"ImageURL"];
    self.videoURL = [json valueForKey:@"VideoURL"];
    self.published = [json valueForKey:@"Published"];
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:9];
    
    [d setValue:self.articleId forKey:@"Id"];
    [d setValue:self.title forKey:@"Title"];
    [d setValue:self.summary forKey:@"Description"];
    [d setValue:self.articleURL forKey:@"ArticleURL"];
    [d setValue:self.imageURL forKey:@"ImageURL"];
    [d setValue:self.videoURL forKey:@"VideoURL"];
    [d setValue:self.published forKey:@"Published"];
    
    return d;
}

@end
