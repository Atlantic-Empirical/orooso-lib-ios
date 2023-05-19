//
//  ORBoard.h
//  Orooso
//
//  Created by Thomas Purnell-Fisher on 7/30/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ORFriend;

@interface ORBoard : NSObject

@property (nonatomic, copy) NSString *boardId;
@property (nonatomic, copy) NSString *ownerId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, assign) BOOL isDefault;
@property (nonatomic, assign) BOOL isPublic;
@property (nonatomic, assign) BOOL isFollowing;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, strong) ORFriend *owner;

+ (id)instanceWithJSON:(NSDictionary *)json;
+ (id)arrayWithJSON:(NSArray *)json;
- (id)initWithJSON:(NSDictionary *)json;
- (NSMutableDictionary *)proxyForJson;

@end
