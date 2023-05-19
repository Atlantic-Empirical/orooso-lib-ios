//
//  ORWikipediaPageExtractQueryPages.h
//  
//
//  Created by Thomas Purnell-Fisher on 4/14/13.
//  Copyright (c) 2013 Orooso Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ORWikipediaPageExtractQueryPage;

@interface ORWikipediaPageExtractQueryPages : NSObject <NSCoding>

@property (nonatomic, strong) ORWikipediaPageExtractQueryPage *queryPage;


+ (ORWikipediaPageExtractQueryPages *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

- (NSDictionary *)dictionaryRepresentation;

@end
