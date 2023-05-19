//
//  OREntity.m
//  
//
//  Created by Thomas Purnell-Fisher on 12/28/12.
//  Copyright (c) 2012 Orooso Inc.. All rights reserved.
//

#import "OREntity.h"
#import "OREntityFilm.h"

@implementation OREntity

+ (NSString *)nameForType:(OREntityType)type
{
    switch (type) {
        case OREntityType_Board: return @"Board";
        case OREntityType_Brand: return @"Brand";
        case OREntityType_City: return @"City";
        case OREntityType_Country: return @"Country";
        case OREntityType_Movie: return @"Film";
        case OREntityType_NewsItem: return @"News Item";
        case OREntityType_Person: return @"Person";
        case OREntityType_RecordingArtist: return @"Recording Artist";
        case OREntityType_SportsTeam: return @"Sports Team";
        case OREntityType_TVChannel: return @"TV Channel";
        case OREntityType_TVNewZealand: return @"TVNZ Show";
        case OREntityType_TVShow: return @"TV Show";
        case OREntityType_Twitter: return @"Twitter";
        case OREntityType_TwitterNews: return @"Twitter News";
        case OREntityType_YouTubeLive: return @"YouTube Live";
        case OREntityType_YouTubeLiveEvent: return @"YouTube Live Event";
        case OREntityType_Undefined: return nil;
    }
}

+ (id)instanceWithJSON:(NSDictionary *)json
{
    // Usually this is inside initWithJSON, but this is a special case
    // because we need to check the Entity type to instance the child class
    if (!json || ![json isKindOfClass:[NSDictionary class]]) return nil;
    
    OREntityType type = [[json valueForKey:@"EntityType"] integerValue];
    
    switch (type) {
        case OREntityType_Movie:
            return [[OREntityFilm alloc] initWithJSON:json];
        default:
            return [[self alloc] initWithJSON:json];
    }
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
    
    self.source = [json valueForKey:@"Source"];
    self.entityId = [json valueForKey:@"EntityId"];
    self.freebaseID = [json valueForKey:@"FreebaseID"];
    self.name = [json valueForKey:@"Name"];
    self.slug = [json valueForKey:@"Slug"];
    self.subtitle = [json valueForKey:@"Subtitle"];
    self.entityDescription = [json valueForKey:@"Description"];
    self.keywords = [json valueForKey:@"Keywords"];
    self.associatedPeople = [json valueForKey:@"AssociatedPeople"];
    self.exclusionStrings = [json valueForKey:@"ExclusionStrings"];
    self.priority = [json valueForKey:@"Priority"];
    self.entityType = [[json valueForKey:@"EntityType"] integerValue];
    self.timeCreated = [json valueForKey:@"TimeCreated"];
    self.timeLastUpdated = [json valueForKey:@"TimeLastUpdated"];
    self.timeLastVerified = [json valueForKey:@"TimeLastVerified"];
    self.urlRepresentativeImage = [json valueForKey:@"UrlRepresentativeImage"];
    self.urlOfficialSite = [json valueForKey:@"UrlOfficialSite"];
    self.urlFacebook = [json valueForKey:@"UrlFacebook"];
    self.urlWikipedia = [json valueForKey:@"UrlWikipedia"];
    self.wikipediaPageId = [json valueForKey:@"WikipediaPageId"];
    self.subreddit = [json valueForKey:@"Subreddit"];
    self.twitterAccounts = [json valueForKey:@"TwitterAccounts"];
    self.hashtags = [json valueForKey:@"Hashtags"];
    self.urlYoutube = [json valueForKey:@"UrlYoutube"];
    self.youtubeChannels = [json valueForKey:@"YoutubeChannels"];
    self.latitude = [[json valueForKey:@"Latitude"] doubleValue];
    self.longitude = [[json valueForKey:@"Longitude"] doubleValue];
    self.isDynamic = [[json valueForKey:@"Dynamic"] integerValue];
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:25];
    
    [d setValue:self.source forKey:@"Source"];
    [d setValue:self.entityId forKey:@"EntityId"];
    [d setValue:self.freebaseID forKey:@"FreebaseID"];
    [d setValue:self.name forKey:@"Name"];
    [d setValue:self.slug forKey:@"Slug"];
    [d setValue:self.subtitle forKey:@"Subtitle"];
    [d setValue:self.entityDescription forKey:@"Description"];
    [d setValue:self.keywords forKey:@"Keywords"];
    [d setValue:self.associatedPeople forKey:@"AssociatedPeople"];
    [d setValue:self.exclusionStrings forKey:@"ExclusionStrings"];
    [d setValue:self.priority forKey:@"Priority"];
    [d setValue:@(self.entityType) forKey:@"EntityType"];
    [d setValue:self.timeCreated forKey:@"TimeCreated"];
    [d setValue:self.timeLastUpdated forKey:@"TimeLastUpdated"];
    [d setValue:self.timeLastVerified forKey:@"TimeLastVerified"];
    [d setValue:self.urlRepresentativeImage forKey:@"UrlRepresentativeImage"];
    [d setValue:self.urlOfficialSite forKey:@"UrlOfficialSite"];
    [d setValue:self.urlFacebook forKey:@"UrlFacebook"];
    [d setValue:self.urlWikipedia forKey:@"UrlWikipedia"];
    [d setValue:self.wikipediaPageId forKey:@"WikipediaPageId"];
    [d setValue:self.subreddit forKey:@"Subreddit"];
    [d setValue:self.twitterAccounts forKey:@"TwitterAccounts"];
    [d setValue:self.hashtags forKey:@"Hashtags"];
    [d setValue:self.urlYoutube forKey:@"UrlYoutube"];
    [d setValue:self.youtubeChannels forKey:@"YoutubeChannels"];
    [d setValue:@(self.latitude) forKey:@"Latitude"];
    [d setValue:@(self.longitude) forKey:@"Longitude"];
    [d setValue:@(self.isDynamic) forKey:@"Dynamic"];
    
    return d;
}

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (!self) return nil;
    self.isLoading = NO;
    
    return self;
}

#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)d
{
    self = [self init];
    
    if (self) {
        self.source = [d decodeObjectForKey:@"Source"];
        self.entityId = [d decodeObjectForKey:@"EntityId"];
        self.freebaseID = [d decodeObjectForKey:@"FreebaseID"];
        self.name = [d decodeObjectForKey:@"Name"];
        self.slug = [d decodeObjectForKey:@"Slug"];
        self.subtitle = [d decodeObjectForKey:@"Subtitle"];
        self.entityDescription = [d decodeObjectForKey:@"Description"];
        self.keywords = [d decodeObjectForKey:@"Keywords"];
        self.associatedPeople = [d decodeObjectForKey:@"AssociatedPeople"];
        self.exclusionStrings = [d decodeObjectForKey:@"ExclusionStrings"];
        self.priority = [d decodeObjectForKey:@"Priority"];
        self.entityType = [d decodeIntegerForKey:@"EntityType"];
        self.timeCreated = [d decodeObjectForKey:@"TimeCreated"];
        self.timeLastUpdated = [d decodeObjectForKey:@"TimeLastUpdated"];
        self.timeLastVerified = [d decodeObjectForKey:@"TimeLastVerified"];
        self.urlRepresentativeImage = [d decodeObjectForKey:@"UrlRepresentativeImage"];
        self.urlOfficialSite = [d decodeObjectForKey:@"UrlOfficialSite"];
        self.urlFacebook = [d decodeObjectForKey:@"UrlFacebook"];
        self.urlWikipedia = [d decodeObjectForKey:@"UrlWikipedia"];
        self.twitterAccounts = [d decodeObjectForKey:@"TwitterAccounts"];
        self.hashtags = [d decodeObjectForKey:@"Hashtags"];
        self.wikipediaPageId = [d decodeObjectForKey:@"WikipediaPageId"];
        self.subreddit = [d decodeObjectForKey:@"Subreddit"];
        self.latitude = [d decodeDoubleForKey:@"Latitude"];
        self.longitude = [d decodeDoubleForKey:@"Longitude"];
        self.isDynamic = [d decodeBoolForKey:@"Dynamic"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)c
{
    [c encodeObject:self.source forKey:@"Source"];
    [c encodeObject:self.entityId forKey:@"EntityId"];
    [c encodeObject:self.freebaseID forKey:@"FreebaseID"];
    [c encodeObject:self.name forKey:@"Name"];
    [c encodeObject:self.slug forKey:@"Slug"];
    [c encodeObject:self.subtitle forKey:@"Subtitle"];
    [c encodeObject:self.entityDescription forKey:@"Description"];
    [c encodeObject:self.keywords forKey:@"Keywords"];
    [c encodeObject:self.associatedPeople forKey:@"AssociatedPeople"];
    [c encodeObject:self.exclusionStrings forKey:@"ExclusionStrings"];
    [c encodeObject:self.priority forKey:@"Priority"];
    [c encodeInteger:self.entityType forKey:@"EntityType"];
    [c encodeObject:self.timeCreated forKey:@"TimeCreated"];
    [c encodeObject:self.timeLastUpdated forKey:@"TimeLastUpdated"];
    [c encodeObject:self.timeLastVerified forKey:@"TimeLastVerified"];
    [c encodeObject:self.urlRepresentativeImage forKey:@"UrlRepresentativeImage"];
    [c encodeObject:self.urlOfficialSite forKey:@"UrlOfficialSite"];
    [c encodeObject:self.urlFacebook forKey:@"UrlFacebook"];
    [c encodeObject:self.urlWikipedia forKey:@"UrlWikipedia"];
    [c encodeObject:self.twitterAccounts forKey:@"TwitterAccounts"];
    [c encodeObject:self.hashtags forKey:@"Hashtags"];
    [c encodeObject:self.wikipediaPageId forKey:@"WikipediaPageId"];
    [c encodeObject:self.subreddit forKey:@"Subreddit"];
    [c encodeDouble:self.latitude forKey:@"Latitude"];
    [c encodeDouble:self.longitude forKey:@"Longitude"];
    [c encodeBool:self.isDynamic forKey:@"Dynamic"];
}

- (NSString*)urlEntityLinkWithSource:(NSString *)source
{
    NSString *url = nil;
	if (self.isDynamic)
		url = [NSString stringWithFormat:@"http://portl.it/d/%@", [self.name or_urlPathEncodedString]];
	else
		url = [NSString stringWithFormat:@"http://portl.it/e/%@/%d", self.entityId, self.entityType];
    
    return (source) ? [NSString stringWithFormat:@"%@?src=%@", url, source] : url;
}

- (NSString *)urlTwitter
{
    if (self.twitterAccounts && self.twitterAccounts.count > 0) {
        return [NSString stringWithFormat:@"http://twitter.com/%@", [self.twitterAccounts[0] stringByReplacingOccurrencesOfString:@"@" withString:@""]];
    } else {
        return nil;
    }
}

@end
