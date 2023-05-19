//
//  ORTVNZArticle.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 13/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ORTVNZArticle : NSObject

@property (nonatomic, copy) NSString *articleId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSString *articleURL;
@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, copy) NSString *videoURL;
@property (nonatomic, copy) NSString *published;

+ (id)instanceWithJSON:(NSDictionary *)json;
+ (id)arrayWithJSON:(NSArray *)json;
- (id)initWithJSON:(NSDictionary *)json;
- (NSMutableDictionary *)proxyForJson;

@end
