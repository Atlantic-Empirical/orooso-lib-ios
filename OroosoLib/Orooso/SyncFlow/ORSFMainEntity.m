//
//  ORSFMainEntity.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 02/08/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFMainEntity.h"
#import "OREntity.h"

@implementation ORSFMainEntity

- (id)initWithEntity:(OREntity *)entity
{
    self = [super init];
    
    if (self) {
        self.itemID = entity.entityId;
		self.parentEntity = entity;
        self.type = SFItemTypeMainEntity;
        self.title = entity.name;
        self.imageURL = [NSURL URLWithString:entity.urlRepresentativeImage];
    }
    
    return self;
}

@end
