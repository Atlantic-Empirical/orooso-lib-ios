//
//  ORIGImage.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 10/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ORInstagramUser;

@interface ORInstagramImage : NSObject

@property (nonatomic, copy) NSString *imageID;
@property (nonatomic, copy) NSString *attribution;
@property (nonatomic, copy) NSString *captionCreatedTime;
@property (nonatomic, strong) ORInstagramUser *captionAuthor;
@property (nonatomic, copy) NSString *captionID;
@property (nonatomic, copy) NSString *captionText;
@property (nonatomic, assign) NSUInteger commentCount;
@property (nonatomic, assign) NSUInteger likeCount;
@property (nonatomic, copy) NSString *createdTime;
@property (nonatomic, copy) NSString *filter;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSArray *tags;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong) ORInstagramUser *user;
@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) CGFloat longitude;

@property (nonatomic, copy) NSString *imageStandard;
@property (nonatomic, copy) NSString *imageLow;
@property (nonatomic, copy) NSString *imageThumbnail;

+ (id)instanceWithJSON:(NSDictionary *)json;
+ (id)arrayWithJSON:(NSArray *)json;
- (id)initWithJSON:(NSDictionary *)json;
- (NSMutableDictionary *)proxyForJson;

+ (id)instanceWithIGJSON:(NSDictionary *)json;
+ (id)arrayWithIGJSON:(NSArray *)json;
- (id)initWithIGJSON:(NSDictionary *)json;

@end
