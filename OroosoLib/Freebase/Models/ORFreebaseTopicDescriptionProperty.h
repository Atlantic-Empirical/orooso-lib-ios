//
//  ORMyClassProperty.h
//  
//
//  Created by Thomas Purnell-Fisher on 4/13/13.
//  Copyright (c) 2013 Orooso Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ORFreebaseTopicDescriptionPropertyCommonTopicDescription;

@interface ORFreebaseTopicDescriptionProperty : NSObject <NSCoding>

@property (nonatomic, strong) ORFreebaseTopicDescriptionPropertyCommonTopicDescription *CommonTopicDescription;


+ (ORFreebaseTopicDescriptionProperty *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

- (NSDictionary *)dictionaryRepresentation;

@end
