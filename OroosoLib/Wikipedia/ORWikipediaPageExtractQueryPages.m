//
//  ORWikipediaPageExtractQueryPages.m
//  
//
//  Created by Thomas Purnell-Fisher on 4/14/13.
//  Copyright (c) 2013 Orooso Inc.. All rights reserved.
//

#import "ORWikipediaPageExtractQueryPages.h"

#import "ORWikipediaPageExtractQueryPage.h"

@implementation ORWikipediaPageExtractQueryPages

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.queryPage forKey:@"19831"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init])) {
        self.queryPage = [decoder decodeObjectForKey:@"19831"];
    }
    return self;
}

+ (ORWikipediaPageExtractQueryPages *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    ORWikipediaPageExtractQueryPages *instance = [[ORWikipediaPageExtractQueryPages alloc] init];
    [instance setAttributesFromDictionary:aDictionary];
    return instance;

}

- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary
{

    if (![aDictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }

    [self setValuesForKeysWithDictionary:aDictionary];

}

- (void)setValue:(id)value forKey:(NSString *)key
{
	self.queryPage = [ORWikipediaPageExtractQueryPage instanceFromDictionary:value];
//	int keyInt = (int)key;
//    if ([key isEqualToString:@"19831"]) {
//        if ([value isKindOfClass:[NSDictionary class]]) {
//            self.queryPage = [ORWikipediaPageExtractQueryPage instanceFromDictionary:value];
//        }
//    } else {
//        [super setValue:value forKey:key];
//    }
}

- (NSDictionary *)dictionaryRepresentation
{

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    if (self.queryPage) {
        [dictionary setObject:self.queryPage forKey:@"19831"];
    }

    return dictionary;

}

@end
