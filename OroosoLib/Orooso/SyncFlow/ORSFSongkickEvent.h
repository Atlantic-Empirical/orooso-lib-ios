//
//  ORSFSKEvent.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 11/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFItem.h"

@class ORSongkickEvent;

@interface ORSFSongkickEvent : ORSFItem

@property (nonatomic, strong) ORSongkickEvent *event;

- (id)initWithSKEvent:(ORSongkickEvent *)event andEntity:(OREntity*)entity;

@end
