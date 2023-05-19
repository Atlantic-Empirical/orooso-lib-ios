//
//  ORIMDBTitle.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 27/09/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

@interface ORImdbTitle : NSObject

@property (nonatomic, assign) BOOL exact;
@property (nonatomic, assign) BOOL popular;

@property (nonatomic, strong) NSString* episodeTitle;
@property (nonatomic, strong) NSString* imdbDescription;
@property (nonatomic, strong) NSString* imdbID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString* titleDescription;
@property (nonatomic, strong) NSString *url;


+ (ORImdbTitle *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;
- (NSDictionary *)dictionaryRepresentation;

@end
