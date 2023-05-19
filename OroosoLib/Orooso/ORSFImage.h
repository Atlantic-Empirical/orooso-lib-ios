//
//  ORSFImage.h
//  OroosoLib
//
//  Created by Thomas Purnell-Fisher on 1/22/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFItem.h"

@class ORImage;

@interface ORSFImage : ORSFItem

@property (nonatomic, strong) ORImage *image;

- (id)initWithImage:(ORImage *)image andEntity:(OREntity*)entity;
- (id)initWithORURL:(ORURL *)url andEntity:(OREntity*)entity;

@end
