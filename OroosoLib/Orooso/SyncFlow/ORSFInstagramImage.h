//
//  ORSFIGImage.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 10/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFItem.h"

@class ORInstagramImage;

@interface ORSFInstagramImage : ORSFItem

@property (nonatomic, strong) ORInstagramImage *image;

- (id)initWithIGImage:(ORInstagramImage *)image andEntity:(OREntity*)entity;

@end
