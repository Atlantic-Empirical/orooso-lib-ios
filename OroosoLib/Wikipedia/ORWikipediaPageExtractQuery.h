//
//  ORWikipediaPageExtractQuery.h
//  
//
//  Created by Thomas Purnell-Fisher on 4/14/13.
//  Copyright (c) 2013 Orooso Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ORWikipediaPageExtractQueryPages;

@interface ORWikipediaPageExtractQuery : NSObject <NSCoding>

@property (nonatomic, strong) ORWikipediaPageExtractQueryPages *pages;


+ (ORWikipediaPageExtractQuery *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

- (NSDictionary *)dictionaryRepresentation;

@end
