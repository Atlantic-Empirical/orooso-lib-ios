//
//  ORITunesObject.h
//  OroosoLib
//
//  Created by Thomas Purnell-Fisher on 3/26/13.
//  strongright (c) 2013 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ORITunesObject : NSObject <NSCoding>

@property (nonatomic, strong) NSNumber *artistId;
@property (nonatomic, strong) NSString *artistName;
@property (nonatomic, strong) id artistViewUrl;
@property (nonatomic, strong) NSString *artworkUrl100;
@property (nonatomic, strong) NSString *artworkUrl60;
@property (nonatomic, strong) id collectionCensoredName;
@property (nonatomic, strong) NSString *collectionExplicitness;
@property (nonatomic, strong) NSNumber *collectionId;
@property (nonatomic, strong) id collectionName;
@property (nonatomic, strong) NSNumber *collectionPrice;
@property (nonatomic, strong) id collectionViewUrl;
@property (nonatomic, strong) NSString *contentAdvisoryRating;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *currency;
@property (nonatomic, strong) NSNumber *discCount;
@property (nonatomic, strong) NSNumber *discNumber;
@property (nonatomic, strong) NSNumber *iTunesId;
@property (nonatomic, strong) NSString *kind;
@property (nonatomic, strong) NSString *shortDescription;
@property (nonatomic, strong) NSString *longDescription;
@property (nonatomic, strong) NSString *previewUrl;
@property (nonatomic, strong) NSString *primaryGenreName;
@property (nonatomic, strong) NSString *searchURL;
@property (nonatomic, strong) NSString *releaseDate;
@property (nonatomic, strong) NSString *trackCensoredName;
@property (nonatomic, strong) NSNumber *trackCount;
@property (nonatomic, strong) NSString *trackExplicitness;
@property (nonatomic, strong) NSNumber *trackId;
@property (nonatomic, strong) NSString *trackName;
@property (nonatomic, strong) NSNumber *trackNumber;
@property (nonatomic, strong) NSNumber *trackPrice;
@property (nonatomic, strong) NSNumber *trackTimeMillis;
@property (nonatomic, strong) NSString *trackViewUrl;
@property (nonatomic, strong) NSString *wrapperType;

// Helpers
- (NSString *)name;

+ (id)instanceWithJSON:(NSDictionary *)json;
+ (id)arrayWithJSON:(NSArray *)json;
- (id)initWithJSON:(NSDictionary *)json;
- (NSMutableDictionary *)proxyForJson;

@end
