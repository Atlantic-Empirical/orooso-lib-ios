//
//  ORWikipediaPageExtractQueryPage.h
//  
//
//  Created by Thomas Purnell-Fisher on 4/14/13.
//  Copyright (c) 2013 Orooso Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ORWikipediaPageExtractQueryPage : NSObject <NSCoding>

@property (nonatomic, copy) NSString *extract;
@property (nonatomic, copy) NSNumber *ns;
@property (nonatomic, copy) NSNumber *pageid;
@property (nonatomic, copy) NSString *title;


+ (ORWikipediaPageExtractQueryPage *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

- (NSDictionary *)dictionaryRepresentation;

@end
