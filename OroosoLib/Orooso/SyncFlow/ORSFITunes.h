//
//  ORSFITunesGeneric.h
//  OroosoLib
//
//  Created by Thomas Purnell-Fisher on 3/26/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFItem.h"

@class ORITunesObject;

@interface ORSFITunes : ORSFItem

@property (nonatomic, strong) ORITunesObject *itunesObject;

- (ORSFITunes *)initWithITunesObject:(ORITunesObject *)itObject andEntity:(OREntity *)entity;

@end
