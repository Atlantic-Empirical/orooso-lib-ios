//
//  ORSFWebsite.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 17/04/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFWebsite.h"
#import "ORURL.h"

@implementation ORSFWebsite

- (id)initWithJSON:(NSDictionary *)json
{
    self = [super initWithJSON:json];
    if (!self) return nil;
    
    self.imageName = [json valueForKey:@"ImageName"];
    self.avatarName = [json valueForKey:@"AvatarName"];
    
    if (!self.imageURL) self.imageName = @"website-placeholder";
    if (!self.avatarURL) self.avatarName = @"website-50x";
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [super proxyForJson];
    
    [d setValue:self.imageName forKey:@"ImageName"];
    [d setValue:self.avatarName forKey:@"AvatarName"];
    
    return d;
}

- (id)initWithURLString:(NSString *)url andEntity:(OREntity *)entity
{
    return [self initWithORURL:[ORURL URLWithURLString:url] andEntity:entity];
}

- (id)initWithORURL:(ORURL *)url andEntity:(OREntity *)entity
{
    self = [super init];
    
    if (self) {
        self.itemID = url.finalURL.absoluteString;
        self.detailURL = url;
		self.parentEntity = entity;
        self.type = SFItemTypeWebsite;
        self.imageName = @"website-placeholder";
        self.avatarName = @"website-50x";
        self.imageURL = url.imageURL;
    }
    
    return self;
}

- (void)setImageURL:(NSURL *)imageURL
{
    [super setImageURL:imageURL];
    if (imageURL) self.imageName = nil;
}

- (UIImage *)mainImage
{
    if (self.imageName) {
        return [UIImage imageNamed:self.imageName];
    } else {
        return [super mainImage];
    }
}

- (UIImage *)avatarImage
{
    if (self.avatarName) {
        return [UIImage imageNamed:self.avatarName];
    } else {
        return [super avatarImage];
    }
}

@end
