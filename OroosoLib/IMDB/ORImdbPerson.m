//
//  ORIMDBPerson.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 28/09/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "ORIMDBPerson.h"

@implementation ORImdbPerson

- (NSString *)description
{
    return [NSString stringWithFormat:@"[ORIMDBPerson] %@ (%@), ID: %@",
            self.name, self.imdbDescription, self.imdbID];
}

#pragma mark - Initialization

- (id)initWithJSON:(NSDictionary *)jsonData
{
    self = [super init];
    if (self) [self parseJSON:jsonData];
    return self;
}

#pragma mark - JSON Parsing

- (void)parseJSON:(NSDictionary *)jsonData
{
    self.imdbID = [jsonData objectForKey:@"id"];
    self.title = [jsonData objectForKey:@"title"];
    self.name = [jsonData objectForKey:@"name"];
    self.imdbDescription = [jsonData objectForKey:@"description"];
}

@end
