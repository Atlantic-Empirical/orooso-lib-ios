//
//  ORUrl.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 28/11/2012.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

typedef enum _ORURLType {
    ORURLTypeUnknown,
    ORURLTypeImage,
    ORURLTypeInstagram,
    ORURLTypeYoutube,
    ORURLTypeTwitpic,
    ORURLTypeYfrog,
    ORURLTypeTwitterMedia,
    ORURLTypePage,
    ORURLTypeImgur
} ORURLType;

@class ORImage;

@interface ORURL : NSObject <NSCoding>

@property (nonatomic, copy) NSURL *originalURL;
@property (nonatomic, copy) NSURL *finalURL;
@property (nonatomic, copy) NSURL *imageURL;
@property (nonatomic, copy) NSURL *faviconURL;
@property (nonatomic, copy) NSURL *shortcutIconURL;
@property (nonatomic, copy) NSString *displayURL;
@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, copy) NSString *customData;
@property (nonatomic, copy) NSString *keywords;
@property (nonatomic, copy) NSString *pageDescription;
@property (nonatomic, copy) NSString *pageTitle;
@property (nonatomic, assign) ORURLType type;
@property (nonatomic, copy) NSDate *resolveStarted;
@property (nonatomic, assign) BOOL isResolving;
@property (nonatomic, assign) BOOL isResolved;
@property (nonatomic, weak) MKNetworkOperation *resolveOperation;
@property (strong, nonatomic) NSMutableArray *indices;

// Twitter
@property (nonatomic, copy) NSString *twitterSite;
@property (nonatomic, copy) NSString *twitterCreator;
@property (nonatomic, copy) NSString *twitterTitle;
@property (nonatomic, copy) NSString *twitterDescription;
@property (nonatomic, copy) NSString *twitterImage;

+ (id)instanceWithJSON:(NSDictionary *)json;
+ (id)arrayWithJSON:(NSArray *)json;
- (id)initWithJSON:(NSDictionary *)json;
- (NSMutableDictionary *)proxyForJson;
+ (NSMutableArray *)proxyForJsonWithArray:(NSArray *)array;

+ (id)URLWithURL:(NSURL *)url;
+ (id)URLWithURLString:(NSString *)urlString;
+ (id)URLWithTwitterMedia:(NSDictionary *)json;
+ (id)URLWithTwitterURL:(NSDictionary *)json;
+ (id)URLWithHeaders:(NSDictionary *)headers;
+ (id)URLWithORImage:(ORImage *)image;

- (id)initWithURL:(NSURL *)url;
- (id)initWithURLString:(NSString *)urlString;
- (id)initWithTwitterMedia:(NSDictionary *)json;
- (id)initWithTwitterURL:(NSDictionary *)json;
- (id)initWithHeaders:(NSDictionary *)headers;
- (id)initWithORImage:(ORImage *)image;

- (BOOL)replaceKnownQueryParams;
- (void)copyDataFrom:(ORURL *)other;

@end
