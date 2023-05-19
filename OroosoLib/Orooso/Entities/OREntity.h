//
//  OREntity.h
//  
//
//  Created by Thomas Purnell-Fisher on 12/28/12.
//  Copyright (c) 2012 Orooso Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

// Important: never change the type number, needs to be in-sync with server
typedef enum _OREntityType {
    OREntityType_Undefined = 0,
    OREntityType_TVShow = 1,
    OREntityType_Movie = 2,
    OREntityType_Person = 3,
	OREntityType_TVChannel = 4,
    OREntityType_SportsTeam = 5,
    OREntityType_RecordingArtist = 6,
    OREntityType_NewsItem = 7,
    OREntityType_City = 8,
    OREntityType_Country = 9,
    OREntityType_Twitter = 10,
    OREntityType_TwitterNews = 11,
    OREntityType_YouTubeLiveEvent = 12,
    OREntityType_YouTubeLive = 13,
    OREntityType_TVNewZealand = 14,
    OREntityType_Brand = 15,
    OREntityType_Board = 16
} OREntityType;

@interface OREntity : NSObject <NSCoding>

// Storage
@property (nonatomic, copy) NSString *source;
 
// Core Info
@property (nonatomic, copy) NSString *entityId;
@property (nonatomic, copy) NSString *freebaseID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *slug;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *entityDescription;
@property (nonatomic, copy) NSArray *keywords;
@property (nonatomic, copy) NSArray *associatedPeople;
@property (nonatomic, copy) NSArray *exclusionStrings;
@property (nonatomic, copy) NSString *priority;

// Type
@property (nonatomic, assign) OREntityType entityType;
@property (nonatomic, assign) BOOL isDynamic;

// Timestamps
@property (nonatomic, copy) NSString *timeCreated;
@property (nonatomic, copy) NSString *timeLastUpdated;
@property (nonatomic, copy) NSString *timeLastVerified;

// Images
@property (nonatomic, copy) NSString *urlRepresentativeImage;

// Sites
@property (nonatomic, copy) NSString *urlOfficialSite;
@property (nonatomic, copy) NSString *urlFacebook;
@property (nonatomic, copy) NSString *urlWikipedia;
@property (nonatomic, copy) NSString *wikipediaPageId;
@property (nonatomic, copy) NSString *subreddit;

// Twitter
@property (nonatomic, copy) NSArray *twitterAccounts;
@property (nonatomic, copy) NSArray *hashtags;
@property (nonatomic, readonly) NSString *urlTwitter;

// Videos
@property (nonatomic, strong) NSString *urlYoutube;
@property (nonatomic, strong) NSString *youtubeChannels;

// SFE Related
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isOnline;

// Location
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

+ (NSString *)nameForType:(OREntityType)type;
+ (id)instanceWithJSON:(NSDictionary *)json;
+ (id)arrayWithJSON:(NSArray *)json;
- (id)initWithJSON:(NSDictionary *)json;
- (NSMutableDictionary *)proxyForJson;
- (NSString *)urlEntityLinkWithSource:(NSString *)source;

@end
