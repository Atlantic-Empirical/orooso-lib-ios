//
//  ORImage.m
//  OroosoLib
//
//  Created by Thomas Purnell-Fisher on 7/25/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "ORImage.h"
#import "ORCachedEngine.h"
#import "ORConstants.h"

@interface ORImage ()
{
    BOOL _isLoadingImage;
}

@property (nonatomic, weak) MKNetworkOperation *loadingOP;

@end

@implementation ORImage

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
    
    self.copyrightInfo = [json valueForKey:@"CopyrightInfo"];
    self.type = [[json valueForKey:@"Type"] integerValue];
    self.associatedItemId = [json valueForKey:@"AssociatedItemId"];
    self.contentType = [json valueForKey:@"ContentType"];
    self.displayUrl = [json valueForKey:@"DisplayUrl"];
    self.width = [[json valueForKey:@"Width"] integerValue];
    self.height = [[json valueForKey:@"Height"] integerValue];
    self.fileSize = [[json valueForKey:@"FileSize"] integerValue];
    self.idOrooso = [json valueForKey:@"IdOrooso"];
    self.idProvider = [json valueForKey:@"IdProvider"];
    self.mediaUrl = [json valueForKey:@"MediaUrl"];
    self.origQuery = [json valueForKey:@"originalQuery"];
    self.provider = [json valueForKey:@"Provider"];
    self.qualityScore = [json valueForKey:@"QualityScore"];
    self.sourceUrl = [json valueForKey:@"SourceUrl"];
    self.thumbContentType = [json valueForKey:@"Thumb_ContentType"];
    self.thumbWidth = [[json valueForKey:@"Thumb_Width"] integerValue];
    self.thumbHeight = [[json valueForKey:@"Thumb_Height"] integerValue];
    self.thumbFilesize = [[json valueForKey:@"Thumb_Filesize"] integerValue];
    self.thumbMediaUrl = [json valueForKey:@"Thumb_MediaUrl"];
    self.title = [json valueForKey:@"Title"];
    self.parsed = [[json valueForKey:@"Parsed"] boolValue];
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:25];
    
    [d setValue:self.copyrightInfo forKey:@"CopyrightInfo"];
    [d setValue:@(self.type) forKey:@"Type"];
    [d setValue:self.associatedItemId forKey:@"AssociatedItemId"];
    [d setValue:self.contentType forKey:@"ContentType"];
    [d setValue:self.displayUrl forKey:@"DisplayUrl"];
    [d setValue:@(self.width) forKey:@"Width"];
    [d setValue:@(self.height) forKey:@"Height"];
    [d setValue:@(self.fileSize) forKey:@"FileSize"];
    [d setValue:self.idOrooso forKey:@"IdOrooso"];
    [d setValue:self.idProvider forKey:@"IdProvider"];
    [d setValue:self.mediaUrl forKey:@"MediaUrl"];
    [d setValue:self.origQuery forKey:@"originalQuery"];
    [d setValue:self.provider forKey:@"Provider"];
    [d setValue:self.qualityScore forKey:@"QualityScore"];
    [d setValue:self.sourceUrl forKey:@"SourceUrl"];
    [d setValue:self.thumbContentType forKey:@"Thumb_ContentType"];
    [d setValue:@(self.thumbWidth) forKey:@"Thumb_Width"];
    [d setValue:@(self.thumbHeight) forKey:@"Thumb_Height"];
    [d setValue:@(self.thumbFilesize) forKey:@"Thumb_Filesize"];
    [d setValue:self.thumbMediaUrl forKey:@"Thumb_MediaUrl"];
    [d setValue:self.title forKey:@"Title"];
    [d setValue:@(self.parsed) forKey:@"Parsed"];
    
    return d;
}

- (id)init
{
    self = [super init];
    if (!self) return nil;

    _isLoadingImage = NO;
    _image = nil;
    
    return self;
}

-(ORImage*)initWithUrlString:(NSString*)urlString andType:(ORImageType)nType
{
	self = [self init];
    if (!self) return nil;
    
    self.mediaUrl = urlString;
    self.type = nType;

	return self;
}

- (ORImage*)initWithUIImage:(UIImage*)image andTitle:(NSString*)title {
	self = [self init];
	if (!self) return nil;
    
    self.image = image;
    self.title = title;

	return self;
}

-(ORImage*)initDummy
{
	self = [self init];
	return self;
}

+ (ORImage *)instanceWithOnlyMediaUrl:(NSString *)mediaUrl
{
	ORImage *instance = [[ORImage alloc] init];
	instance.mediaUrl = mediaUrl;
	return instance;
}

- (void)loadImage
{
    if (self.image) {
        _isLoadingImage = NO;
        if (self.delegate) [self.delegate image:self imageLoaded:self.image local:YES];
        return;
    }
    
    if (!_isLoadingImage) {
        _isLoadingImage = YES;
        if (self.delegate) [self.delegate imageIsLoading:self];
        
        NSURL *url = [NSURL URLWithString:self.mediaUrl];
        
        if (!url) {
            if (self.delegate) [self.delegate imageFailedToLoad:self];
            return;
        }
        
        CGFloat size = (ISIPAD) ? 1024.0f : 568.0f;
        CGSize maxSize = CGSizeMake(size, size);
        
        self.loadingOP = [[ORCachedEngine sharedInstance] imageAtURL:url size:maxSize fill:NO completion:^(NSError *error, MKNetworkOperation *op, UIImage *image, BOOL cached) {
            _isLoadingImage = NO;
            self.loadingOP = nil;

            if (error) {
                NSLog(@"Error Loading Image: %@", error);
                if (self.delegate) [self.delegate imageFailedToLoad:self];
                return;
            }
            
            if (self.delegate) [self.delegate image:self imageLoaded:image local:cached];
        }];
    }
}

- (void)cancelLoad
{
    if (self.loadingOP) {
        [self.loadingOP cancel];
        
        self.loadingOP = nil;
        _isLoadingImage = NO;
    }
}

- (NSString *)mediaURLwithType:(ORImageType)type
{
    if (self.parsed) {
        switch (type) {
            case ORImageTypeOriginal: {
                return self.mediaUrl;
            }
            case ORImageTypeCard: {
                if ([[UIScreen mainScreen] scale] >= 2.0f) {
                    return [self.mediaUrl stringByReplacingOccurrencesOfString:@"_original." withString:@"_card_2x."];
                } else {
                    return [self.mediaUrl stringByReplacingOccurrencesOfString:@"_original." withString:@"_card."];
                }
            }
            case ORImageTypeThumb: {
                return [self.mediaUrl stringByReplacingOccurrencesOfString:@"_original." withString:@"_thumb."];
            }
        }
    } else {
        return self.mediaUrl;
    }
}

#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)d
{
    self = [super init];
    
    if (self) {
        self.size = [d decodeCGSizeForKey:@"Size"];
        self.copyrightInfo = [d decodeObjectForKey:@"CopyrightInfo"];
        self.type = [d decodeIntegerForKey:@"Type"];
        self.associatedItemId = [d decodeObjectForKey:@"AssociatedItemId"];
        self.contentType = [d decodeObjectForKey:@"ContentType"];
        self.displayUrl = [d decodeObjectForKey:@"DisplayUrl"];
        self.width = [d decodeIntegerForKey:@"Width"];
        self.height = [d decodeIntegerForKey:@"Height"];
        self.fileSize = [d decodeIntegerForKey:@"FileSize"];
        self.idOrooso = [d decodeObjectForKey:@"IdOrooso"];
        self.idProvider = [d decodeObjectForKey:@"IdProvider"];
        self.mediaUrl = [d decodeObjectForKey:@"MediaUrl"];
        self.origQuery = [d decodeObjectForKey:@"OrigQuery"];
        self.provider = [d decodeObjectForKey:@"Provider"];
        self.qualityScore = [d decodeObjectForKey:@"QualityScore"];
        self.sourceUrl = [d decodeObjectForKey:@"SourceUrl"];
        self.thumbContentType = [d decodeObjectForKey:@"ThumbContentType"];
        self.thumbWidth = [d decodeIntegerForKey:@"ThumbWidth"];
        self.thumbHeight = [d decodeIntegerForKey:@"ThumbHeight"];
        self.thumbFilesize = [d decodeIntegerForKey:@"ThumbFilesize"];
        self.thumbMediaUrl = [d decodeObjectForKey:@"ThumbMediaUrl"];
        self.title = [d decodeObjectForKey:@"Title"];
        self.parsed = [d decodeBoolForKey:@"Parsed"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)c
{
    [c encodeCGSize:self.size forKey:@"Size"];
    [c encodeObject:self.copyrightInfo forKey:@"CopyrightInfo"];
    [c encodeInteger:self.type forKey:@"Type"];
    [c encodeObject:self.associatedItemId forKey:@"AssociatedItemId"];
    [c encodeObject:self.contentType forKey:@"ContentType"];
    [c encodeObject:self.displayUrl forKey:@"DisplayUrl"];
    [c encodeInteger:self.width forKey:@"Width"];
    [c encodeInteger:self.height forKey:@"Height"];
    [c encodeInteger:self.fileSize forKey:@"FileSize"];
    [c encodeObject:self.idOrooso forKey:@"IdOrooso"];
    [c encodeObject:self.idProvider forKey:@"IdProvider"];
    [c encodeObject:self.mediaUrl forKey:@"MediaUrl"];
    [c encodeObject:self.origQuery forKey:@"OrigQuery"];
    [c encodeObject:self.provider forKey:@"Provider"];
    [c encodeObject:self.qualityScore forKey:@"QualityScore"];
    [c encodeObject:self.sourceUrl forKey:@"SourceUrl"];
    [c encodeObject:self.thumbContentType forKey:@"ThumbContentType"];
    [c encodeInteger:self.thumbWidth forKey:@"ThumbWidth"];
    [c encodeInteger:self.thumbHeight forKey:@"ThumbHeight"];
    [c encodeInteger:self.thumbFilesize forKey:@"ThumbFilesize"];
    [c encodeObject:self.thumbMediaUrl forKey:@"ThumbMediaUrl"];
    [c encodeObject:self.title forKey:@"Title"];
    [c encodeBool:self.parsed forKey:@"Parsed"];
}

@end
