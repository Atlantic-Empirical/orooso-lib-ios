//
//  ORValue.h
//  
//
//  Created by Thomas Purnell-Fisher on 4/13/13.
//  Copyright (c) 2013 Orooso Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ORFreebaseTopicDescriptionValueCitation;

@interface ORFreebaseTopicDescriptionValue : NSObject <NSCoding>

@property (nonatomic, strong) ORFreebaseTopicDescriptionValueCitation *citation;
@property (nonatomic, copy) NSString *creator;
@property (nonatomic, copy) NSString *dataset;
@property (nonatomic, copy) NSString *lang;
@property (nonatomic, copy) NSString *project;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *value;

+ (ORFreebaseTopicDescriptionValue *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

- (NSDictionary *)dictionaryRepresentation;

@end
