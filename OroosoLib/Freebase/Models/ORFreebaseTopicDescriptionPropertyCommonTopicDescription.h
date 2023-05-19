//
//  ORMyClassPropertyCommonTopicDescription.h
//  
//
//  Created by Thomas Purnell-Fisher on 4/13/13.
//  Copyright (c) 2013 Orooso Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ORFreebaseTopicDescriptionPropertyCommonTopicDescription : NSObject <NSCoding>

@property (nonatomic, strong) NSNumber *count;
@property (nonatomic, strong) NSArray *values;
@property (nonatomic, strong) NSString *valuetype;


+ (ORFreebaseTopicDescriptionPropertyCommonTopicDescription *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

- (NSDictionary *)dictionaryRepresentation;

@end
