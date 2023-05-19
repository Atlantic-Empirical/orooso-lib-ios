//
//  ORITunesObject.m
//  OroosoLib
//
//  Created by Thomas Purnell-Fisher on 3/26/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORITunesObject.h"

@implementation ORITunesObject

+ (id)instanceWithJSON:(NSDictionary *)json
{
    return [[self alloc] initWithJSON:json];
}

+ (id)arrayWithJSON:(NSArray *)json
{
    if (!json || ![json isKindOfClass:[NSArray class]]) return nil;
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:json.count];
    
    for (NSDictionary *dict in json) {
        id item = [self instanceWithJSON:dict];
        if (item) [items addObject:item];
    }
    
    return items;
}

- (id)initWithJSON:(NSDictionary *)json
{
    self = [super init];
    if (!self) return nil;
    if (!json || ![json isKindOfClass:[NSDictionary class]]) return nil;
    
    self.artistId = [json valueForKey:@"ArtistId"];
    self.artistName = [json valueForKey:@"ArtistName"];
    self.artistViewUrl = [json valueForKey:@"ArtistViewUrl"];
    self.artworkUrl100 = [json valueForKey:@"ArtworkUrl100"];
    self.artworkUrl60 = [json valueForKey:@"ArtworkUrl60"];
    self.collectionCensoredName = [json valueForKey:@"CollectionCensoredName"];
    self.collectionExplicitness = [json valueForKey:@"CollectionExplicitness"];
    self.collectionId = [json valueForKey:@"CollectionId"];
    self.collectionName = [json valueForKey:@"CollectionName"];
    self.collectionPrice = [json valueForKey:@"CollectionPrice"];
    self.collectionViewUrl = [json valueForKey:@"CollectionViewUrl"];
    self.contentAdvisoryRating = [json valueForKey:@"ContentAdvisoryRating"];
    self.country = [json valueForKey:@"Country"];
    self.currency = [json valueForKey:@"Currency"];
    self.discCount = [json valueForKey:@"DiscCount"];
    self.discNumber = [json valueForKey:@"DiscNumber"];
    self.iTunesId = [json valueForKey:@"ITunesId"];
    self.kind = [json valueForKey:@"Kind"];
    self.shortDescription = [json valueForKey:@"ShortDescription"];
    self.longDescription = [json valueForKey:@"LongDescription"];
    self.previewUrl = [json valueForKey:@"PreviewUrl"];
    self.primaryGenreName = [json valueForKey:@"PrimaryGenreName"];
    self.searchURL = [json valueForKey:@"SearchURL"];
    self.releaseDate = [json valueForKey:@"ReleaseDate"];
    self.trackCensoredName = [json valueForKey:@"TrackCensoredName"];
    self.trackCount = [json valueForKey:@"TrackCount"];
    self.trackExplicitness = [json valueForKey:@"TrackExplicitness"];
    self.trackId = [json valueForKey:@"TrackId"];
    self.trackName = [json valueForKey:@"TrackName"];
    self.trackNumber = [json valueForKey:@"TrackNumber"];
    self.trackPrice = [json valueForKey:@"TrackPrice"];
    self.trackTimeMillis = [json valueForKey:@"TrackTimeMillis"];
    self.trackViewUrl = [json valueForKey:@"TrackViewUrl"];
    self.wrapperType = [json valueForKey:@"WrapperType"];
    
    if ([json valueForKey:@"Description"]) {
        if (!self.shortDescription) self.shortDescription = [json valueForKey:@"Description"];
        if (!self.longDescription) self.longDescription = [json valueForKey:@"Description"];
    }
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:34];
    
    [d setValue:self.artistId forKey:@"ArtistId"];
    [d setValue:self.artistName forKey:@"ArtistName"];
    [d setValue:self.artistViewUrl forKey:@"ArtistViewUrl"];
    [d setValue:self.artworkUrl100 forKey:@"ArtworkUrl100"];
    [d setValue:self.artworkUrl60 forKey:@"ArtworkUrl60"];
    [d setValue:self.collectionCensoredName forKey:@"CollectionCensoredName"];
    [d setValue:self.collectionExplicitness forKey:@"CollectionExplicitness"];
    [d setValue:self.collectionId forKey:@"CollectionId"];
    [d setValue:self.collectionName forKey:@"CollectionName"];
    [d setValue:self.collectionPrice forKey:@"CollectionPrice"];
    [d setValue:self.collectionViewUrl forKey:@"CollectionViewUrl"];
    [d setValue:self.contentAdvisoryRating forKey:@"ContentAdvisoryRating"];
    [d setValue:self.country forKey:@"Country"];
    [d setValue:self.currency forKey:@"Currency"];
    [d setValue:self.discCount forKey:@"DiscCount"];
    [d setValue:self.discNumber forKey:@"DiscNumber"];
    [d setValue:self.iTunesId forKey:@"ITunesId"];
    [d setValue:self.kind forKey:@"Kind"];
    [d setValue:self.shortDescription forKey:@"ShortDescription"];
    [d setValue:self.longDescription forKey:@"LongDescription"];
    [d setValue:self.previewUrl forKey:@"PreviewUrl"];
    [d setValue:self.primaryGenreName forKey:@"PrimaryGenreName"];
    [d setValue:self.searchURL forKey:@"SearchURL"];
    [d setValue:self.releaseDate forKey:@"ReleaseDate"];
    [d setValue:self.trackCensoredName forKey:@"TrackCensoredName"];
    [d setValue:self.trackCount forKey:@"TrackCount"];
    [d setValue:self.trackExplicitness forKey:@"TrackExplicitness"];
    [d setValue:self.trackId forKey:@"TrackId"];
    [d setValue:self.trackName forKey:@"TrackName"];
    [d setValue:self.trackNumber forKey:@"TrackNumber"];
    [d setValue:self.trackPrice forKey:@"TrackPrice"];
    [d setValue:self.trackTimeMillis forKey:@"TrackTimeMillis"];
    [d setValue:self.trackViewUrl forKey:@"TrackViewUrl"];
    [d setValue:self.wrapperType forKey:@"WrapperType"];
    
    return d;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.artistId forKey:@"artistId"];
    [encoder encodeObject:self.artistName forKey:@"artistName"];
    [encoder encodeObject:self.artistViewUrl forKey:@"artistViewUrl"];
    [encoder encodeObject:self.artworkUrl100 forKey:@"artworkUrl100"];
    [encoder encodeObject:self.artworkUrl60 forKey:@"artworkUrl60"];
    [encoder encodeObject:self.collectionCensoredName forKey:@"collectionCensoredName"];
    [encoder encodeObject:self.collectionExplicitness forKey:@"collectionExplicitness"];
    [encoder encodeObject:self.collectionId forKey:@"collectionId"];
    [encoder encodeObject:self.collectionName forKey:@"collectionName"];
    [encoder encodeObject:self.collectionPrice forKey:@"collectionPrice"];
    [encoder encodeObject:self.collectionViewUrl forKey:@"collectionViewUrl"];
    [encoder encodeObject:self.contentAdvisoryRating forKey:@"contentAdvisoryRating"];
    [encoder encodeObject:self.country forKey:@"country"];
    [encoder encodeObject:self.currency forKey:@"currency"];
    [encoder encodeObject:self.discCount forKey:@"discCount"];
    [encoder encodeObject:self.discNumber forKey:@"discNumber"];
    [encoder encodeObject:self.iTunesId forKey:@"ITunesId"];
    [encoder encodeObject:self.kind forKey:@"kind"];
    [encoder encodeObject:self.longDescription forKey:@"longDescription"];
    [encoder encodeObject:self.previewUrl forKey:@"previewUrl"];
    [encoder encodeObject:self.primaryGenreName forKey:@"primaryGenreName"];
    [encoder encodeObject:self.searchURL forKey:@"searchURL"];
    [encoder encodeObject:self.releaseDate forKey:@"releaseDate"];
    [encoder encodeObject:self.shortDescription forKey:@"shortDescription"];
    [encoder encodeObject:self.trackCensoredName forKey:@"trackCensoredName"];
    [encoder encodeObject:self.trackCount forKey:@"trackCount"];
    [encoder encodeObject:self.trackExplicitness forKey:@"trackExplicitness"];
    [encoder encodeObject:self.trackId forKey:@"trackId"];
    [encoder encodeObject:self.trackName forKey:@"trackName"];
    [encoder encodeObject:self.trackNumber forKey:@"trackNumber"];
    [encoder encodeObject:self.trackPrice forKey:@"trackPrice"];
    [encoder encodeObject:self.trackTimeMillis forKey:@"trackTimeMillis"];
    [encoder encodeObject:self.trackViewUrl forKey:@"trackViewUrl"];
    [encoder encodeObject:self.wrapperType forKey:@"wrapperType"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init])) {
        self.artistId = [decoder decodeObjectForKey:@"artistId"];
        self.artistName = [decoder decodeObjectForKey:@"artistName"];
        self.artistViewUrl = [decoder decodeObjectForKey:@"artistViewUrl"];
        self.artworkUrl100 = [decoder decodeObjectForKey:@"artworkUrl100"];
        self.artworkUrl60 = [decoder decodeObjectForKey:@"artworkUrl60"];
        self.collectionCensoredName = [decoder decodeObjectForKey:@"collectionCensoredName"];
        self.collectionExplicitness = [decoder decodeObjectForKey:@"collectionExplicitness"];
        self.collectionId = [decoder decodeObjectForKey:@"collectionId"];
        self.collectionName = [decoder decodeObjectForKey:@"collectionName"];
        self.collectionPrice = [decoder decodeObjectForKey:@"collectionPrice"];
        self.collectionViewUrl = [decoder decodeObjectForKey:@"collectionViewUrl"];
        self.contentAdvisoryRating = [decoder decodeObjectForKey:@"contentAdvisoryRating"];
        self.country = [decoder decodeObjectForKey:@"country"];
        self.currency = [decoder decodeObjectForKey:@"currency"];
        self.discCount = [decoder decodeObjectForKey:@"discCount"];
        self.discNumber = [decoder decodeObjectForKey:@"discNumber"];
        self.iTunesId = [decoder decodeObjectForKey:@"ITunesId"];
        self.kind = [decoder decodeObjectForKey:@"kind"];
        self.longDescription = [decoder decodeObjectForKey:@"longDescription"];
        self.previewUrl = [decoder decodeObjectForKey:@"previewUrl"];
        self.primaryGenreName = [decoder decodeObjectForKey:@"primaryGenreName"];
        self.searchURL = [decoder decodeObjectForKey:@"searchURL"];
        self.releaseDate = [decoder decodeObjectForKey:@"releaseDate"];
        self.shortDescription = [decoder decodeObjectForKey:@"shortDescription"];
        self.trackCensoredName = [decoder decodeObjectForKey:@"trackCensoredName"];
        self.trackCount = [decoder decodeObjectForKey:@"trackCount"];
        self.trackExplicitness = [decoder decodeObjectForKey:@"trackExplicitness"];
        self.trackId = [decoder decodeObjectForKey:@"trackId"];
        self.trackName = [decoder decodeObjectForKey:@"trackName"];
        self.trackNumber = [decoder decodeObjectForKey:@"trackNumber"];
        self.trackPrice = [decoder decodeObjectForKey:@"trackPrice"];
        self.trackTimeMillis = [decoder decodeObjectForKey:@"trackTimeMillis"];
        self.trackViewUrl = [decoder decodeObjectForKey:@"trackViewUrl"];
        self.wrapperType = [decoder decodeObjectForKey:@"wrapperType"];
    }
    return self;
}

- (NSString *)name
{
    if ([self.wrapperType isEqualToString:@"collection"]) return self.collectionName;
    if ([self.wrapperType isEqualToString:@"artist"]) return self.artistName;
	
	if ([self.kind isEqualToString:@"tv-episode"])
		return [NSString stringWithFormat:@"Episode: %@", self.trackName];
	else
		return self.trackName;
}

@end
