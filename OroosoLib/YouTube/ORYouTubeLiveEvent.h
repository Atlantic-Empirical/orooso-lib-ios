//
//  ORYouTubeLiveEvent.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 11/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ORYouTubeLiveEvent : NSObject

@property (nonatomic, copy) NSString *region;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *videoID;
@property (nonatomic, copy) NSString *videoURL;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *videoDescription;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *authorURL;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *thumbnailURL;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *start;
@property (nonatomic, copy) NSString *end;
@property (nonatomic, copy) NSString *published;
@property (nonatomic, assign) NSUInteger duration;
@property (nonatomic, assign) NSUInteger views;
@property (nonatomic, assign) NSUInteger currentViewers;
@property (nonatomic, assign) NSUInteger favorites;
@property (nonatomic, assign) NSUInteger likes;
@property (nonatomic, assign) NSUInteger dislikes;

+ (id)instanceWithJSON:(NSDictionary *)json;
+ (id)arrayWithJSON:(NSArray *)json;
- (id)initWithJSON:(NSDictionary *)json;
- (NSMutableDictionary *)proxyForJson;

@end
