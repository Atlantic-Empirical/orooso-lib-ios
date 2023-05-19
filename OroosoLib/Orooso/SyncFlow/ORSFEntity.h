//
//  ORSFEntity.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 02/05/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFItem.h"

@interface ORSFEntity : ORSFItem

@property (nonatomic, strong) OREntity *entity;

- (id)initWithEntity:(OREntity *)entity parentEntity:(OREntity *)parentEntity;

@end
