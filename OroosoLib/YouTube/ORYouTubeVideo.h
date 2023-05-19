//
//  ORYouTubeVideo.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 07/09/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

@interface ORYouTubeVideo : NSObject

@property (copy, nonatomic) NSString *queryString;
@property (copy, nonatomic) NSString *source;
@property (assign, nonatomic) int positionInSearchResults;

@property (copy, nonatomic) NSString *videoID;
@property (copy, nonatomic) NSString *videoURL;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *videoDescription;
@property (copy, nonatomic) NSString *author;
@property (copy, nonatomic) NSString *authorURL;
@property (copy, nonatomic) NSString *category;
@property (copy, nonatomic) NSString *published;
@property (copy, nonatomic) NSNumber *duration;
@property (copy, nonatomic) NSNumber *views;
@property (copy, nonatomic) NSNumber *favorites;
@property (copy, nonatomic) NSNumber *likes;
@property (copy, nonatomic) NSNumber *dislikes;
@property (copy, nonatomic) NSString *thumbnailURL;
@property (copy, nonatomic, readonly) NSString *thumbnailURL_maxres;
@property (copy, nonatomic, readonly) NSString *thumbnailURL_hqdefault;
@property (copy, nonatomic, readonly) NSString *urlShort;
@property (assign, nonatomic) BOOL isMobileRestricted;

+ (id)instanceWithJSON:(NSDictionary *)json;
+ (id)arrayWithJSON:(NSArray *)json;
- (id)initWithJSON:(NSDictionary *)json;
- (NSMutableDictionary *)proxyForJson;

- (id)initWithYTJSON:(NSDictionary *)jsonData;
- (void)parseYTJSON:(NSDictionary *)jsonData;
+ (NSString*)thumbnailURLHqDefaultForVideoID:(NSString*)videoID;

@end
