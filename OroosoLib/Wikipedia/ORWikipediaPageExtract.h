//
//  ORWikipediaPageExtract.h
//  
//
//  Created by Thomas Purnell-Fisher on 4/14/13.
//  Copyright (c) 2013 Orooso Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ORWikipediaPageExtractQuery;

@interface ORWikipediaPageExtract : NSObject <NSCoding>

@property (nonatomic, strong) ORWikipediaPageExtractQuery *query;

+ (ORWikipediaPageExtract *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

- (NSDictionary *)dictionaryRepresentation;

@end
