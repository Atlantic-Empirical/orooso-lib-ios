//
//  ORUrl.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 28/11/2012.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "ORURL.h"
#import "ORImage.h"

@implementation ORURL

- (NSString *)description
{
    NSString *type = nil;
    
    switch (self.type) {
        case ORURLTypeImage:        type = @"Image"; break;
        case ORURLTypeInstagram:    type = @"Instagram"; break;
        case ORURLTypeYoutube:      type = @"YouTube"; break;
        case ORURLTypeTwitpic:      type = @"TwitPic"; break;
        case ORURLTypeYfrog:        type = @"yFrog"; break;
        case ORURLTypeImgur:        type = @"Imgur"; break;
        case ORURLTypeTwitterMedia: type = @"Twitter Media"; break;
        case ORURLTypePage:         type = @"Page"; break;
        default:                    type = @"Unknown"; break;
    }
    
    return [NSString stringWithFormat:@"ORURL {\n"
            "  Original URL: %@\n"
            "  Final URL:    %@\n"
            "  Image URL:    %@\n"
            "  Type:         %@\n"
            "  Resolved:     %d\n"
            "  Resolve Time: %f\n"
            "}", self.originalURL, self.finalURL, self.imageURL, type, self.isResolved,
            [[NSDate date] timeIntervalSinceDate:self.resolveStarted]];
}

+ (id)URLWithURL:(NSURL *)url
{
    return ([[ORURL alloc] initWithURL:url]);
}

+ (id)URLWithURLString:(NSString *)urlString
{
    if (!urlString) return nil;
    return ([[ORURL alloc] initWithURLString:urlString]);
}

+ (id)URLWithTwitterMedia:(NSDictionary *)json
{
    return ([[ORURL alloc] initWithTwitterMedia:json]);
}

+ (id)URLWithTwitterURL:(NSDictionary *)json
{
    return ([[ORURL alloc] initWithTwitterURL:json]);
}

+ (id)URLWithHeaders:(NSDictionary *)headers
{
    return ([[ORURL alloc] initWithHeaders:headers]);
}

+ (id)URLWithORImage:(ORImage *)image
{
    return ([[ORURL alloc] initWithORImage:image]);
}

+ (id)instanceWithJSON:(NSDictionary *)json
{
    if ([json isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithURLString:(NSString *)json];
    } else {
        return [[self alloc] initWithJSON:json];
    }
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
    
    if (![[json valueForKey:@"shortURL"] isKindOfClass:[NSNull class]]) self.originalURL = [NSURL URLWithString:[json valueForKey:@"shortURL"]];
    if (![[json valueForKey:@"contentType"] isKindOfClass:[NSNull class]]) self.contentType = [json valueForKey:@"contentType"];
    if (![[json valueForKey:@"expandedUrl"] isKindOfClass:[NSNull class]]) self.finalURL = [NSURL URLWithString:[json valueForKey:@"expandedUrl"]];
    if (![[json valueForKey:@"imageUrl"] isKindOfClass:[NSNull class]]) self.imageURL = [NSURL URLWithString:[json valueForKey:@"imageUrl"]];
    if (![[json valueForKey:@"shortcutIconUrl"] isKindOfClass:[NSNull class]]) self.shortcutIconURL = [NSURL URLWithString:[json valueForKey:@"shortcutIconUrl"]];
    if (![[json valueForKey:@"faviconUrl"] isKindOfClass:[NSNull class]]) self.faviconURL = [NSURL URLWithString:[json valueForKey:@"faviconUrl"]];
    if (![[json valueForKey:@"keywords"] isKindOfClass:[NSNull class]]) self.keywords = [json valueForKey:@"keywords"];
    if (![[json valueForKey:@"pageTitle"] isKindOfClass:[NSNull class]]) self.pageTitle = [json valueForKey:@"pageTitle"];
    if (![[json valueForKey:@"description"] isKindOfClass:[NSNull class]]) self.pageDescription = [json valueForKey:@"description"];
    if (![[json valueForKey:@"twitterSite"] isKindOfClass:[NSNull class]]) self.twitterSite = [json valueForKey:@"twitterSite"];
    if (![[json valueForKey:@"twitterCreator"] isKindOfClass:[NSNull class]]) self.twitterCreator = [json valueForKey:@"twitterCreator"];
    if (![[json valueForKey:@"twitterTitle"] isKindOfClass:[NSNull class]]) self.twitterTitle = [json valueForKey:@"twitterTitle"];
    if (![[json valueForKey:@"twitterDescription"] isKindOfClass:[NSNull class]]) self.twitterDescription = [json valueForKey:@"twitterDescription"];
    if (![[json valueForKey:@"twitterImage"] isKindOfClass:[NSNull class]]) self.twitterImage = [json valueForKey:@"twitterImage"];
    
    if ([json valueForKey:@"type"]) {
        self.type = [[json valueForKey:@"type"] integerValue];
    } else {
        self.type = ORURLTypeUnknown;
        if ([self.contentType hasPrefix:@"text/html"]) self.type = ORURLTypePage;
        if ([self.contentType hasPrefix:@"image/png"]) self.type = ORURLTypeImage;
        if ([self.contentType hasPrefix:@"image/jpeg"]) self.type = ORURLTypeImage;
        if ([self.contentType hasPrefix:@"image/gif"]) self.type = ORURLTypeImage;
    }
    
    if ([json valueForKey:@"resolved"]) {
        self.isResolved = [[json valueForKey:@"resolved"] boolValue];
    } else {
        self.isResolved = YES;
    }
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:17];
    
    [d setValue:self.originalURL.absoluteString forKey:@"shortURL"];
    [d setValue:self.contentType forKey:@"contentType"];
    [d setValue:self.finalURL.absoluteString forKey:@"expandedUrl"];
    [d setValue:self.imageURL.absoluteString forKey:@"imageUrl"];
    [d setValue:self.shortcutIconURL.absoluteString forKey:@"shortcutIconUrl"];
    [d setValue:self.faviconURL.absoluteString forKey:@"faviconUrl"];
    [d setValue:self.keywords forKey:@"keywords"];
    [d setValue:self.pageTitle forKey:@"pageTitle"];
    [d setValue:self.pageDescription forKey:@"description"];
    [d setValue:self.twitterSite forKey:@"twitterSite"];
    [d setValue:self.twitterCreator forKey:@"twitterCreator"];
    [d setValue:self.twitterTitle forKey:@"twitterTitle"];
    [d setValue:self.twitterDescription forKey:@"twitterDescription"];
    [d setValue:self.twitterImage forKey:@"twitterImage"];
    [d setValue:@(self.type) forKey:@"type"];
    [d setValue:@(self.isResolved) forKey:@"resolved"];
    
    return d;
}

+ (NSMutableArray *)proxyForJsonWithArray:(NSArray *)array
{
    if (!array) return nil;
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:array.count];
    
    for (id item in array) {
        NSDictionary *d = [item proxyForJson];
        if (d) [items addObject:d];
    }
    
    return items;
}

- (id)initWithURL:(NSURL *)url
{
    self = [super init];
    
    if (self) {
        _type = ORURLTypeUnknown;
        _originalURL = [url copy];
        _finalURL = [url copy];
        _isResolving = NO;
        _isResolved = NO;
    }
    
    return self;
}

- (id)initWithURLString:(NSString *)urlString
{
    return [self initWithURL:[NSURL URLWithString:urlString]];
}

- (id)initWithTwitterMedia:(NSDictionary *)json
{
    NSString *shortURL = [json objectForKey:@"url"];
    self = [self initWithURLString:shortURL];
    
    if (self) {
        _type = ORURLTypeTwitterMedia;
        _customData = [[json objectForKey:@"id_str"] copy];
        _imageURL = [NSURL URLWithString:[json objectForKey:@"media_url"]];
        _finalURL = [NSURL URLWithString:[json objectForKey:@"expanded_url"]];
        _displayURL = [[json objectForKey:@"display_url"] copy];
        _isResolved = YES;
        
        self.indices = nil;
        if ([[json objectForKey:@"indices"] isKindOfClass:[NSArray class]]) {
            self.indices = [NSMutableArray arrayWithCapacity:[[json objectForKey:@"indices"] count]];
            
            for (NSNumber *index in [json objectForKey:@"indices"]) {
                [self.indices addObject:index];
            }
        }
    }
    
    return self;
}

- (id)initWithTwitterURL:(NSDictionary *)json
{
    NSString *shortURL = [json objectForKey:@"url"];
    self = [self initWithURLString:shortURL];
    
    if (self) {
        _finalURL = [NSURL URLWithString:[json objectForKey:@"expanded_url"]];
        _displayURL = [NSURL URLWithString:[json objectForKey:@"display_url"]];
        if (!self.finalURL) self.finalURL = self.originalURL;
        
        self.indices = nil;
        if ([[json objectForKey:@"indices"] isKindOfClass:[NSArray class]]) {
            self.indices = [NSMutableArray arrayWithCapacity:[[json objectForKey:@"indices"] count]];
            
            for (NSNumber *index in [json objectForKey:@"indices"]) {
                [self.indices addObject:index];
            }
        }
    }
    
    return self;
}

- (id)initWithHeaders:(NSDictionary *)headers
{
    self = [super init];
    
    if (self) {
        self.type = ORURLTypeUnknown;
        
        if ([headers valueForKey:@"X-Original-URL"]) self.originalURL = [NSURL URLWithString:[headers valueForKey:@"X-Original-URL"]];
        if ([headers valueForKey:@"X-Content-Type"]) self.contentType = [headers valueForKey:@"X-Content-Type"];
        if ([headers valueForKey:@"X-Expanded-URL"]) self.finalURL = [NSURL URLWithString:[headers valueForKey:@"X-Expanded-URL"]];
        if ([headers valueForKey:@"X-Image-URL"]) self.imageURL = [NSURL URLWithString:[headers valueForKey:@"X-Image-URL"]];
        if ([headers valueForKey:@"X-ShortcutIcon-URL"]) self.shortcutIconURL = [NSURL URLWithString:[headers valueForKey:@"X-ShortcutIcon-URL"]];
        if ([headers valueForKey:@"X-Favicon-URL"]) self.faviconURL = [NSURL URLWithString:[headers valueForKey:@"X-Favicon-URL"]];
        if ([headers valueForKey:@"X-Keywords"]) self.keywords = [headers valueForKey:@"X-Keywords"];
        if ([headers valueForKey:@"X-Page-Title"]) self.pageTitle = [headers valueForKey:@"X-Page-Title"];
        if ([headers valueForKey:@"X-Description"]) self.pageDescription = [headers valueForKey:@"X-Description"];
        if ([self.contentType hasPrefix:@"text/html"]) self.type = ORURLTypePage;
        if ([self.contentType hasPrefix:@"image/png"]) self.type = ORURLTypeImage;
        if ([self.contentType hasPrefix:@"image/jpeg"]) self.type = ORURLTypeImage;
        if ([self.contentType hasPrefix:@"image/gif"]) self.type = ORURLTypeImage;
        
        self.isResolving = NO;
        self.isResolved = YES;
    }
    
    return self;
}

- (id)initWithORImage:(ORImage *)image
{
    self = [self initWithURLString:image.mediaUrl];
    
    if (self) {
        _type = ORURLTypeImage;
        _customData = [image.origQuery copy];
        _pageTitle = [image.title copy];
        _imageURL = [_originalURL copy];
        _finalURL = [_originalURL copy];
        _displayURL = [image.displayUrl copy];
        
        _isResolved = YES;
    }
    
    return self;
}

- (NSURL *)urlWithoutKnownQueryParams:(NSURL *)url
{
    if (url.query) {
        NSRange range = [url.query rangeOfString:@"utm_"];
        
        if (range.location != NSNotFound) {
            NSString *old = url.absoluteString;
            NSString *query = [NSString stringWithFormat:@"?%@", url.query];
            NSArray *params = [url.query componentsSeparatedByString:@"&"];
            NSMutableArray *newParams = [NSMutableArray arrayWithCapacity:params.count];
            
            for (NSString *param in params) {
                if (![param hasPrefix:@"utm_"]) [newParams addObject:param];
            }
            
            NSString *newURL = [old stringByReplacingOccurrencesOfString:query withString:@""];
            
            if (newParams.count > 0) {
                newURL = [newURL stringByAppendingFormat:@"?%@", [newParams componentsJoinedByString:@"&"]];
            }
            
            return [NSURL URLWithString:newURL];
        }
    }
    
    return url;
}

- (BOOL)replaceKnownQueryParams
{
    self.originalURL = [self urlWithoutKnownQueryParams:self.originalURL];
    self.finalURL = [self urlWithoutKnownQueryParams:self.finalURL];
    
    return YES;
}

- (void)copyDataFrom:(ORURL *)other
{
    self.finalURL = other.finalURL;
    self.imageURL = other.imageURL;
    self.faviconURL = other.faviconURL;
    self.shortcutIconURL = other.shortcutIconURL;
    self.displayURL = other.displayURL;
    self.contentType = other.contentType;
    self.customData = other.customData;
    self.keywords = other.keywords;
    self.pageDescription = other.pageDescription;
    self.pageTitle = other.pageTitle;
    self.type = other.type;
    self.resolveOperation = other.resolveOperation;
    self.indices = other.indices;
    self.twitterSite = other.twitterSite;
    self.twitterCreator = other.twitterCreator;
    self.twitterTitle = other.twitterTitle;
    self.twitterDescription = other.twitterDescription;
    self.twitterImage = other.twitterImage;
    
    if (!self.isResolved && other.isResolved) self.isResolved = YES;
    if (!self.isResolved && self.pageTitle) self.isResolved = YES;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)c
{
    [c encodeObject:self.originalURL forKey:@"originalURL"];
    [c encodeObject:self.finalURL forKey:@"finalURL"];
    [c encodeObject:self.imageURL forKey:@"imageURL"];
    [c encodeObject:self.faviconURL forKey:@"faviconURL"];
    [c encodeObject:self.shortcutIconURL forKey:@"shortcutIconURL"];
    [c encodeObject:self.displayURL forKey:@"displayURL"];
    [c encodeObject:self.contentType forKey:@"contentType"];
    [c encodeObject:self.customData forKey:@"customData"];
    [c encodeObject:self.keywords forKey:@"keywords"];
    [c encodeObject:self.pageDescription forKey:@"pageDescription"];
    [c encodeObject:self.pageTitle forKey:@"pageTitle"];
    [c encodeInt:self.type forKey:@"type"];
    [c encodeObject:self.resolveStarted forKey:@"resolveStarted"];
    [c encodeBool:self.isResolving forKey:@"isResolving"];
    [c encodeBool:self.isResolved forKey:@"isResolved"];
    [c encodeObject:self.indices forKey:@"indices"];
    [c encodeObject:self.twitterSite forKey:@"twitterSite"];
    [c encodeObject:self.twitterCreator forKey:@"twitterCreator"];
    [c encodeObject:self.twitterTitle forKey:@"twitterTitle"];
    [c encodeObject:self.twitterDescription forKey:@"twitterDescription"];
    [c encodeObject:self.twitterImage forKey:@"twitterImage"];
}

- (id)initWithCoder:(NSCoder *)d
{
    self = [super init];
    if (!self) return nil;
    
    self.originalURL = [d decodeObjectForKey:@"originalURL"];
    self.finalURL = [d decodeObjectForKey:@"finalURL"];
    self.imageURL = [d decodeObjectForKey:@"imageURL"];
    self.faviconURL = [d decodeObjectForKey:@"faviconURL"];
    self.shortcutIconURL = [d decodeObjectForKey:@"shortcutIconURL"];
    self.displayURL = [d decodeObjectForKey:@"displayURL"];
    self.contentType = [d decodeObjectForKey:@"contentType"];
    self.customData = [d decodeObjectForKey:@"customData"];
    self.keywords = [d decodeObjectForKey:@"keywords"];
    self.pageDescription = [d decodeObjectForKey:@"pageDescription"];
    self.pageTitle = [d decodeObjectForKey:@"pageTitle"];
    self.type = [d decodeIntForKey:@"type"];
    self.resolveStarted = [d decodeObjectForKey:@"resolveStarted"];
    self.isResolving = [d decodeBoolForKey:@"isResolving"];
    self.isResolved = [d decodeBoolForKey:@"isResolved"];
    self.indices = [d decodeObjectForKey:@"indices"];
    self.twitterSite = [d decodeObjectForKey:@"twitterSite"];
    self.twitterCreator = [d decodeObjectForKey:@"twitterCreator"];
    self.twitterTitle = [d decodeObjectForKey:@"twitterTitle"];
    self.twitterDescription = [d decodeObjectForKey:@"twitterDescription"];
    self.twitterImage = [d decodeObjectForKey:@"twitterImage"];
    self.resolveOperation = nil;
    
    return self;
}

@end
