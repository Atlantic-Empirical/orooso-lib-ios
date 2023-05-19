//
//  ORFreebaseTopicDescription.h
//  
//
//  Created by Thomas Purnell-Fisher on 4/13/13.
//  Copyright (c) 2013 Orooso Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ORFreebaseTopicDescriptionProperty;

@interface ORFreebaseTopicDescription : NSObject <NSCoding>

@property (nonatomic, strong) NSString *topicDescriptionId;
@property (nonatomic, strong) ORFreebaseTopicDescriptionProperty *property;


+ (ORFreebaseTopicDescription *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

- (NSDictionary *)dictionaryRepresentation;

@end
