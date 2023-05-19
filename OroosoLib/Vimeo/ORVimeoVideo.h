//
//  ORVimeoVideo.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 12/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ORVimeoUser;

@interface ORVimeoVideo : NSObject

@property (nonatomic, copy) NSString *videoID;
@property (nonatomic, copy) NSString *embedPrivacy;
@property (nonatomic, assign) BOOL isHD;
@property (nonatomic, assign) BOOL isLike;
@property (nonatomic, assign) BOOL isWatchLater;
@property (nonatomic, copy) NSString *license;
@property (nonatomic, copy) NSString *privacy;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *modifiedDate;
@property (nonatomic, copy) NSString *uploadDate;
@property (nonatomic, assign) NSUInteger likes;
@property (nonatomic, assign) NSUInteger plays;
@property (nonatomic, assign) NSUInteger comments;
@property (nonatomic, assign) NSUInteger duration;
@property (nonatomic, strong) ORVimeoUser *owner;
@property (nonatomic, copy) NSString *thumbnailURL;
@property (nonatomic, copy) NSString *videoURL;

+ (id)instanceWithJSON:(NSDictionary *)json;
+ (id)arrayWithJSON:(NSArray *)json;
- (id)initWithJSON:(NSDictionary *)json;
- (NSMutableDictionary *)proxyForJson;

+ (id)instanceWithVimeoJSON:(NSDictionary *)json;
+ (id)arrayWithVimeoJSON:(NSArray *)json;
- (id)initWithVimeoJSON:(NSDictionary *)json;

@end
