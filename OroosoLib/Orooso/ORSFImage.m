//
//  ORSFImage.m
//  OroosoLib
//
//  Created by Thomas Purnell-Fisher on 1/22/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFImage.h"
#import "ORImage.h"
#import "ORURL.h"
#import "OREntity.h"
#import "NSString+MKNetworkKitAdditions.h"

#define WEIGHTING_entity_name 1.0f

@implementation ORSFImage

- (id)initWithJSON:(NSDictionary *)json
{
    self = [super initWithJSON:json];
    if (!self) return nil;
    
    if ([json valueForKey:@"Image"]) {
        self.image = [ORImage instanceWithJSON:[json valueForKey:@"Image"]];
    } else {
        ORImage *image = [ORImage instanceWithOnlyMediaUrl:self.imageURL.absoluteString];
        image.type = ORImageTypeOriginal;
        image.origQuery = self.title;
        image.sourceUrl = self.detailURL.originalURL.absoluteString;
        image.title = self.title;
        self.image = image;
    }
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [super proxyForJson];
    
    [d setValue:[self.image proxyForJson] forKey:@"Image"];
    
    return d;
}

- (id)initWithImage:(ORImage *)image andEntity:(OREntity*)entity
{
    self = [super init];
    
    if (self) {
        self.image = image;
		self.parentEntity = entity;
        self.type = SFItemTypeImage;
        self.itemID = [image.mediaUrl mk_md5];
        self.title = image.title;
        self.detailURL = [ORURL URLWithURLString:image.sourceUrl];
        self.imageURL = [NSURL URLWithString:[image mediaURLwithType:ORImageTypeCard]];
    }
    
    return self;
}

- (id)initWithORURL:(ORURL *)url andEntity:(OREntity *)entity
{
    self = [super init];
    
    if (self) {
        self.image = [[ORImage alloc] initWithUrlString:url.imageURL.absoluteString andType:ORImageTypeOriginal];
		self.parentEntity = entity;
        self.type = SFItemTypeImage;
        self.itemID = [url.finalURL.absoluteString mk_md5];
        self.title = url.pageTitle;
        self.detailURL = url;
        self.imageURL = url.imageURL;
    }
    
    return self;
}

- (void)setRawScores
{
    self.rawSubscores = [NSMutableDictionary dictionaryWithCapacity:1];
    self.subscoreWeights = [NSMutableDictionary dictionaryWithCapacity:1];
    
    // 1. Is Entity Name?
    BOOL isEntityName = [[self.image.origQuery stringByReplacingOccurrencesOfString:@"\"" withString:@""] isEqualToString:self.parentEntity.name];
    [self.rawSubscores setObject:@(isEntityName) forKey:@"entity_name"];
    [self.subscoreWeights setObject:@(WEIGHTING_entity_name) forKey:@"entity_name"];
}

@end
