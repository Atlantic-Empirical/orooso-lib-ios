//
//  ORInstantResult.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 01/02/2013.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OREntity.h"

@interface ORInstantResult : NSObject <NSCoding>

@property (assign, nonatomic) OREntityType type;
@property (copy, nonatomic) NSString *entityId;
@property (copy, nonatomic) NSString *freebaseID;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *cardImageURL;
@property (assign, nonatomic) NSUInteger *popularity;
@property (strong, nonatomic) NSString *entityDescription;
@property (strong, nonatomic) NSString *wikipediaPageId;
@property (strong, nonatomic, readonly) NSString *wikipediaUrl;
@property (assign, nonatomic) BOOL isDynamic;
@property (assign, nonatomic) int pinCount;
@property (copy, nonatomic) NSString *typeName;
@property (copy, nonatomic) NSString *source;

+ (id)instanceWithJSON:(NSDictionary *)json;
+ (id)instanceWithFreebaseJSON:(NSDictionary *)json;
+ (id)instanceWithEntity:(OREntity *)entity;


+ (id)arrayWithJSON:(NSArray *)json;
+ (id)arrayWithFreebaseJSON:(NSArray *)json;

- (id)initWithJSON:(NSDictionary *)json;
- (id)initWithFreebaseJSON:(NSDictionary *)json;
- (id)initWithEntity:(OREntity *)entity;

- (NSString *)urlEntityLinkWithSource:(NSString *)source;

@end
