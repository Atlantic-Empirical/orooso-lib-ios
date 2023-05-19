//
//  OREntityFilm.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 17/09/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "OREntityFilm.h"
#import "ISO8601DateFormatter.h"
#import "ORIDValue.h"

@implementation OREntityFilm

- (id)initWithJSON:(NSDictionary *)json
{
    self = [super initWithJSON:json];
    if (!self) return nil;
    
    ISO8601DateFormatter *f = [[ISO8601DateFormatter alloc] init];
    
    self.releaseDate = [f dateFromString:[json valueForKey:@"ReleaseDate"]];
    self.tagline = [json valueForKey:@"Tagline"];
    self.directors = [ORIDValue arrayWithJSON:[json valueForKey:@"Directors"]];
    self.starring = [ORIDValue arrayWithJSON:[json valueForKey:@"Starring"]];
    self.genres = [ORIDValue arrayWithJSON:[json valueForKey:@"Genres"]];
    self.subjects = [ORIDValue arrayWithJSON:[json valueForKey:@"Subjects"]];
    self.executiveProducers = [ORIDValue arrayWithJSON:[json valueForKey:@"ExecutiveProducers"]];
    self.producers = [ORIDValue arrayWithJSON:[json valueForKey:@"producers"]];
    self.writers = [ORIDValue arrayWithJSON:[json valueForKey:@"Writers"]];
    self.storyWriters = [ORIDValue arrayWithJSON:[json valueForKey:@"StoryWriters"]];
    self.runtime = [[json valueForKey:@"Runtime"] integerValue];
    self.country = [json valueForKey:@"Country"];
    self.rating = [json valueForKey:@"Rating"];
    self.trailers = [json valueForKey:@"Trailers"];
    self.soundtracks = [ORIDValue arrayWithJSON:[json valueForKey:@"Soundtracks"]];
    self.songs = [ORIDValue arrayWithJSON:[json valueForKey:@"Songs"]];
    self.prequel = [ORIDValue instanceWithJSON:[json valueForKey:@"Prequel"]];
    self.sequel = [ORIDValue instanceWithJSON:[json valueForKey:@"Sequel"]];
    self.netflixID = [json valueForKey:@"NetflixID"];
    self.appleID = [json valueForKey:@"AppleID"];
    self.trailerAddictID = [json valueForKey:@"TrailerAddictID"];
    self.metacriticID = [json valueForKey:@"MetacriticID"];
    self.rottenTomatoesID = [json valueForKey:@"RottenTomatoesID"];
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [super proxyForJson];
    ISO8601DateFormatter *f = [[ISO8601DateFormatter alloc] init];
    
    [d setValue:[f stringFromDate:self.releaseDate] forKey:@"ReleaseDate"];
    [d setValue:self.tagline forKey:@"Tagline"];
    [d setValue:[ORIDValue proxyForJsonWithArray:self.directors] forKey:@"Directors"];
    [d setValue:[ORIDValue proxyForJsonWithArray:self.starring] forKey:@"Starring"];
    [d setValue:[ORIDValue proxyForJsonWithArray:self.genres] forKey:@"Genres"];
    [d setValue:[ORIDValue proxyForJsonWithArray:self.subjects] forKey:@"Subjects"];
    [d setValue:[ORIDValue proxyForJsonWithArray:self.executiveProducers] forKey:@"ExecutiveProducers"];
    [d setValue:[ORIDValue proxyForJsonWithArray:self.producers] forKey:@"Producers"];
    [d setValue:[ORIDValue proxyForJsonWithArray:self.writers] forKey:@"Writers"];
    [d setValue:[ORIDValue proxyForJsonWithArray:self.storyWriters] forKey:@"StoryWriters"];
    [d setValue:@(self.runtime) forKey:@"Runtime"];
    [d setValue:self.country forKey:@"Country"];
    [d setValue:self.rating forKey:@"Rating"];
    [d setValue:self.trailers forKey:@"Trailers"];
    [d setValue:[ORIDValue proxyForJsonWithArray:self.soundtracks] forKey:@"Soundtracks"];
    [d setValue:[ORIDValue proxyForJsonWithArray:self.songs] forKey:@"Songs"];
    [d setValue:[self.prequel proxyForJson] forKey:@"Prequel"];
    [d setValue:[self.sequel proxyForJson] forKey:@"Sequel"];
    [d setValue:self.netflixID forKey:@"NetflixID"];
    [d setValue:self.appleID forKey:@"AppleID"];
    [d setValue:self.trailerAddictID forKey:@"TrailerAddictID"];
    [d setValue:self.metacriticID forKey:@"MetacriticID"];
    [d setValue:self.rottenTomatoesID forKey:@"RottenTomatoesID"];
    
    return d;
}

@end
