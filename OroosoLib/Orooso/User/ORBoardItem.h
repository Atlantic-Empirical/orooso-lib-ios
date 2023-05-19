//
//  ORBoardItem.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 11/07/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ORSFItem;

@interface ORBoardItem : NSObject

@property (nonatomic, copy) NSString *boardId;
@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, copy) NSString *ownerId;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) ORSFItem *item;

+ (id)instanceWithJSON:(NSDictionary *)json;
+ (id)arrayWithJSON:(NSArray *)json;
- (id)initWithJSON:(NSDictionary *)json;
- (NSMutableDictionary *)proxyForJson;

- (id)initWithItem:(ORSFItem *)item;

@end
