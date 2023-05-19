//
//  ORIMDBTitle.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 27/09/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "ORImdbTitle.h"

@implementation ORImdbTitle

- (NSString *)description
{
    return [NSString stringWithFormat:@"[ORIMDBTitle] %@ (%@), ID: %@",
            self.title, self.imdbDescription, self.imdbID];
}

+ (ORImdbTitle *)instanceFromDictionary:(NSDictionary *)aDictionary
{
	
    ORImdbTitle *instance = [[ORImdbTitle alloc] init];
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
    @try {
        [super setValue:value forKey:key];
    }
    @catch (NSException *e) {
        NSLog(@"*** WARN: Tried to set a value to a key that doesn't exist: %@ ***", key);
    }
}

- (NSDictionary *)dictionaryRepresentation
{
	
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	
    if (self.episodeTitle) {
        [dictionary setObject:self.episodeTitle forKey:@"episodeTitle"];
    }
	
    [dictionary setObject:[NSNumber numberWithBool:self.exact] forKey:@"exact"];
	
    if (self.imdbDescription) {
        [dictionary setObject:self.imdbDescription forKey:@"imdbDescription"];
    }
	
    if (self.imdbID) {
        [dictionary setObject:self.imdbID forKey:@"imdbID"];
    }
	
    if (self.name) {
        [dictionary setObject:self.name forKey:@"name"];
    }
	
    [dictionary setObject:[NSNumber numberWithBool:self.popular] forKey:@"popular"];
	
    if (self.source) {
        [dictionary setObject:self.source forKey:@"source"];
    }
	
    if (self.title) {
        [dictionary setObject:self.title forKey:@"title"];
    }
	
    if (self.titleDescription) {
        [dictionary setObject:self.titleDescription forKey:@"titleDescription"];
    }
	
    if (self.url) {
        [dictionary setObject:self.url forKey:@"url"];
    }
	
    return dictionary;
	
}

@end
