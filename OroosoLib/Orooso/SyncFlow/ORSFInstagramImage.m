//
//  ORSFIGImage.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 10/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFInstagramImage.h"
#import "ORInstagramImage.h"
#import "ORInstagramUser.h"
#import "ORURL.h"

@implementation ORSFInstagramImage

- (id)initWithJSON:(NSDictionary *)json
{
    self = [super initWithJSON:json];
    if (!self) return nil;
    
    self.image = [ORInstagramImage instanceWithJSON:[json valueForKey:@"Image"]];
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [super proxyForJson];
    
    [d setValue:[self.image proxyForJson] forKey:@"Image"];
    
    return d;
}

- (id)initWithIGImage:(ORInstagramImage *)image andEntity:(OREntity*)entity
{
    self = [super init];
    
    if (self) {
        self.type = SFItemTypeIGImage;
        self.itemID = image.imageID;
        self.detailURL = [ORURL URLWithURLString:image.link];
        self.imageURL = [NSURL URLWithString:image.imageStandard];
        self.title = image.user.fullName;
        self.content = image.captionText;
        self.avatarURL = [NSURL URLWithString:@"http://s3.amazonaws.com/portl-static/instagram-50x.png"];
		self.parentEntity = entity;
        self.image = image;
    }
    
    return self;
}

- (void)setRawScores
{
    
}

@end
