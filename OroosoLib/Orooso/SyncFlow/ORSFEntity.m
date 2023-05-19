//
//  ORSFEntity.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 02/05/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFEntity.h"
#import "OREntity.h"
#import "ORApiEngine.h"
#import "ORImage.h"

@implementation ORSFEntity

- (id)initWithJSON:(NSDictionary *)json
{
    self = [super initWithJSON:json];
    if (!self) return nil;
    
    self.entity = [OREntity instanceWithJSON:[json valueForKey:@"Entity"]];
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [super proxyForJson];
    
    [d setValue:[self.entity proxyForJson] forKey:@"Entity"];
    
    return d;
}

- (id)initWithEntity:(OREntity *)entity parentEntity:(OREntity *)parentEntity
{
    self = [super init];
    
    if (self) {
        self.itemID = entity.entityId;
        self.entity = entity;
		self.parentEntity = parentEntity;
        self.type = SFItemTypeEntity;
        self.title = entity.name;
        self.content = entity.subtitle;
        self.imageURL = [NSURL URLWithString:entity.urlRepresentativeImage];
        if (!entity.urlRepresentativeImage) [self loadRepresentativeImage];
    }
    
    return self;
}

- (void)loadRepresentativeImage
{
    __weak ORSFEntity *weakSelf = self;
    ORApiEngine *apiEngine = [ORApiEngine sharedInstance];
    
    [apiEngine representativeImage:self.entity.name cb:^(NSError *error, ORImage *image) {
        if (error) {
            NSLog(@"Error Loading Rep Image: %@", error);
        } else {
            weakSelf.entity.urlRepresentativeImage = image.mediaUrl;
            self.imageURL = [NSURL URLWithString:image.mediaUrl];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.delegate) [self.delegate itemDetailURLResolved:self];
            });
        }
    }];
}

@end
