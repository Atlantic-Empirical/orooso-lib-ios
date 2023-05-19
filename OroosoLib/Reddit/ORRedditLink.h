//
//  ORRedditLink.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 27/09/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

@interface ORRedditLink : NSObject

@property (nonatomic, copy) NSString *kind;
@property (nonatomic, copy) NSString *domain;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *thumbnail;
@property (nonatomic, copy) NSString *permalink;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) NSUInteger *score;
@property (nonatomic, assign) NSUInteger *ups;
@property (nonatomic, assign) NSUInteger *downs;
@property (nonatomic, assign) NSUInteger *comments;
@property (nonatomic, assign) NSUInteger *created;
@property (nonatomic, assign) BOOL *isSelf;
@property (nonatomic, assign) BOOL *isOver18;

@property (nonatomic, copy) NSString *mediaType;
@property (nonatomic, copy) NSString *mediaThumbnail;

@property (nonatomic, readonly) NSString *permalinkUrl;

+ (id)instanceWithJSON:(NSDictionary *)json;
+ (id)arrayWithJSON:(NSArray *)json;
- (id)initWithJSON:(NSDictionary *)json;

@end
