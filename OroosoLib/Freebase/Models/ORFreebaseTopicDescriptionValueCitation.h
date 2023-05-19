//
//  ORValueCitation.h
//  
//
//  Created by Thomas Purnell-Fisher on 4/13/13.
//  Copyright (c) 2013 Orooso Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ORFreebaseTopicDescriptionValueCitation : NSObject <NSCoding>

@property (nonatomic, copy) NSString *provider;
@property (nonatomic, copy) NSString *statement;
@property (nonatomic, copy) NSString *uri;


+ (ORFreebaseTopicDescriptionValueCitation *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

- (NSDictionary *)dictionaryRepresentation;

@end
