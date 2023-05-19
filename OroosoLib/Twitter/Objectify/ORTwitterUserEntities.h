//
//  ORTwitterUserEntities.h
//  
//
//  Created by Thomas Purnell-Fisher on 1/22/13.
//  Copyright (c) 2013 Orooso Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ORTwitterUserEntitiesDescription;

@interface ORTwitterUserEntities : NSObject <NSCoding>

@property (nonatomic, strong) ORTwitterUserEntitiesDescription *descriptionText;


+ (ORTwitterUserEntities *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

- (NSDictionary *)dictionaryRepresentation;

@end
