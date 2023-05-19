//
//  ORITunesApp.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 04/10/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ORITunesApp : NSObject

@property (nonatomic, assign) NSUInteger appId;
@property (nonatomic, copy) NSString *bundleId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *genre;
@property (nonatomic, copy) NSString *authorUrl;
@property (nonatomic, copy) NSString *artworkUrl;
@property (nonatomic, copy) NSString *authorName;
@property (nonatomic, copy) NSString *sellerName;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *fullDescription;
@property (nonatomic, copy) NSString *currency;
@property (nonatomic, copy) NSString *releaseDate;
@property (nonatomic, copy) NSString *releaseNotes;
@property (nonatomic, copy) NSString *appViewURL;
@property (nonatomic, copy) NSString *fileSize;
@property (nonatomic, assign) double price;

+ (id)instanceWithJSON:(NSDictionary *)json;
+ (id)arrayWithJSON:(NSArray *)json;
- (id)initWithJSON:(NSDictionary *)json;

@end
