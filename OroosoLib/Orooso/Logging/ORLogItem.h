//
//  ORLogItem.h
//  Orooso
//
//  Created by Thomas Purnell-Fisher on 8/9/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ORLogItem : NSObject

- (ORLogItem*)initWithTrackId:(NSString*)trackId andUtcSkew:(NSUInteger)utcSkewSeconds;

@property (strong, nonatomic) NSString* trackId;
@property (strong, nonatomic) NSDictionary* parameters;
@property (strong, nonatomic) NSString *timestamp;

- (NSMutableDictionary*) proxyForJson;

@end
