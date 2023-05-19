//
//  OREntityFilm.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 17/09/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "OREntity.h"

@class ORIDValue;

@interface OREntityFilm : OREntity

@property (nonatomic, copy) NSDate *releaseDate;
@property (nonatomic, copy) NSString *tagline;
@property (nonatomic, strong) NSArray *directors;
@property (nonatomic, strong) NSArray *starring;
@property (nonatomic, strong) NSArray *genres;
@property (nonatomic, strong) NSArray *subjects;
@property (nonatomic, strong) NSArray *executiveProducers;
@property (nonatomic, strong) NSArray *producers;
@property (nonatomic, strong) NSArray *writers;
@property (nonatomic, strong) NSArray *storyWriters;
@property (nonatomic, assign) NSUInteger runtime;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *rating;
@property (nonatomic, strong) NSArray *trailers;
@property (nonatomic, strong) NSArray *soundtracks;
@property (nonatomic, strong) NSArray *songs;
@property (nonatomic, strong) ORIDValue *prequel;
@property (nonatomic, strong) ORIDValue *sequel;
@property (nonatomic, copy) NSString *netflixID;
@property (nonatomic, copy) NSString *appleID;
@property (nonatomic, copy) NSString *trailerAddictID;
@property (nonatomic, copy) NSString *metacriticID;
@property (nonatomic, copy) NSString *rottenTomatoesID;

@end
