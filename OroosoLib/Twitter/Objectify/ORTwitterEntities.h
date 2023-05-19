//
//  ORTwitterEntities.h
//  
//
//  Created by Thomas Purnell-Fisher on 1/22/13.
//  Copyright (c) 2013 Orooso Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ORTwitterEntities : NSObject <NSCoding>

@property (nonatomic, copy) NSArray *hashtags;
@property (nonatomic, copy) NSArray *urls;
@property (nonatomic, copy) NSArray *userMentions;


+ (ORTwitterEntities *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

- (NSDictionary *)dictionaryRepresentation;

@end
