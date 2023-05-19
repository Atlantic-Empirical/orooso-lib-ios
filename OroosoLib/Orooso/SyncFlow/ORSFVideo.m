//
//  ORSFVideo.m
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 11/01/2013.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFVideo.h"
#import "ORYouTubeVideo.h"
#import "ORYouTubeLiveEvent.h"
#import "ORVimeoVideo.h"
#import "ORTVNZArticle.h"
#import "ORURL.h"

#define WEIGHTING_newness 1.0f
#define WEIGHTING_viewcount 1.0f
#define WEIGHTING_relevance 1.0f

@implementation ORSFVideo

- (id)initWithJSON:(NSDictionary *)json
{
    self = [super initWithJSON:json];
    if (!self) return nil;
    
    self.video = [ORYouTubeVideo instanceWithJSON:[json valueForKey:@"Video"]];
    self.event = [ORYouTubeLiveEvent instanceWithJSON:[json valueForKey:@"Event"]];
    self.vimeoVideo = [ORVimeoVideo instanceWithJSON:[json valueForKey:@"VimeoVideo"]];
    self.tvnzVideo = [ORTVNZArticle instanceWithJSON:[json valueForKey:@"TVNZVideo"]];

    if ([json valueForKey:@"Source"]) {
        self.source = [[json valueForKey:@"Source"] integerValue];
    } else {
        self.source = SFVideoSourceYouTubeVideo;
    }
    
    return self;
}

- (NSMutableDictionary *)proxyForJson
{
    NSMutableDictionary *d = [super proxyForJson];
    
    [d setValue:@(self.source) forKey:@"Source"];
    [d setValue:[self.video proxyForJson] forKey:@"Video"];
    [d setValue:[self.event proxyForJson] forKey:@"Event"];
    [d setValue:[self.vimeoVideo proxyForJson] forKey:@"VimeoVideo"];
    [d setValue:[self.tvnzVideo proxyForJson] forKey:@"TVNZVideo"];
    
    return d;
}

- (id)initWithYouTubeVideo:(ORYouTubeVideo *)video andEntity:(OREntity*)entity
{
    self = [super init];
    if (!self) return nil;
    
    self.type = SFItemTypeVideo;
    self.itemID = video.videoID;
    self.title = video.title;
    self.detailURL = [ORURL URLWithURLString:video.videoURL];
    self.video = video;
    self.event = nil;
    self.vimeoVideo = nil;
    self.tvnzVideo = nil;
    self.parentEntity = entity;
    self.source = SFVideoSourceYouTubeVideo;
    
    NSString *imageURL = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/hqdefault.jpg", video.videoID];
    self.imageURL = [NSURL URLWithString:imageURL];
    
    return self;
}

- (id)initWithYouTubeLiveEvent:(ORYouTubeLiveEvent *)video andEntity:(OREntity *)entity
{
    self = [super init];
    if (!self) return nil;
    
    self.type = SFItemTypeVideo;
    self.itemID = video.videoID;
    self.title = video.title;
    self.detailURL = [ORURL URLWithURLString:video.videoURL];
    self.parentEntity = entity;
    self.event = video;
    self.video = nil;
    self.vimeoVideo = nil;
    self.tvnzVideo = nil;
    self.source = SFVideoSourceYouTubeLive;
    
    NSString *imageURL = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/hqdefault.jpg", video.videoID];
    self.imageURL = [NSURL URLWithString:imageURL];
    
    return self;
}

- (id)initWithVimeoVideo:(ORVimeoVideo *)video andEntity:(OREntity *)entity
{
    self = [super init];
    if (!self) return nil;
    
    self.type = SFItemTypeVideo;
    self.itemID = video.videoID;
    self.title = video.title;
    self.detailURL = [ORURL URLWithURLString:video.videoURL];
    self.video = nil;
    self.event = nil;
    self.vimeoVideo = video;
    self.tvnzVideo = nil;
    self.parentEntity = entity;
    self.source = SFVideoSourceVimeoVideo;
    self.imageURL = [NSURL URLWithString:video.thumbnailURL];
    
    return self;
}

- (id)initWithTVNZArticle:(ORTVNZArticle *)video andEntity:(OREntity *)entity
{
    self = [super init];
    if (!self) return nil;
    
    self.type = SFItemTypeVideo;
    self.itemID = video.articleId;
    self.title = video.title;
    self.detailURL = [ORURL URLWithURLString:video.articleURL];
    self.video = nil;
    self.event = nil;
    self.vimeoVideo = nil;
    self.tvnzVideo = video;
    self.parentEntity = entity;
    self.source = SFVideoSourceTVNZ;
    self.imageURL = [NSURL URLWithString:video.imageURL];
    
    return self;
}

- (id)initWithORURL:(ORURL *)url andEntity:(OREntity *)entity
{
    if (url.type != ORURLTypeYoutube) return nil;
    
    self = [super init];
    if (!self) return nil;
    
    self.type = SFItemTypeVideo;
    self.itemID = url.customData;
    self.title = url.pageTitle;
    self.detailURL = url;
    self.video = nil;
    self.event = nil;
    self.vimeoVideo = nil;
    self.tvnzVideo = nil;
    self.parentEntity = entity;
    self.source = SFVideoSourceYouTubeVideo;
    
    NSString *imageURL = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/hqdefault.jpg", url.customData];
    self.imageURL = [NSURL URLWithString:imageURL];
    
    return self;
}

- (void)setRawScores
{
    if (!self.video) return;
    
	NSLog(@"\n ***** \n SCORING: SET RAW SCORES \n %@ \n *****", self.video.title);
	
	self.rawSubscores = [NSMutableDictionary dictionaryWithCapacity:4];
	
	// Newness
	ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
	NSDate *parsedDate = [formatter dateFromString:self.video.published];
	NSTimeInterval timeInterval = [parsedDate timeIntervalSinceNow];
	[self.rawSubscores setObject:[NSNumber numberWithFloat:(float)timeInterval] forKey:@"newness"];
	NSLog(@"NEWNESS: %f", timeInterval);
	
	// Viewcount
	[self.rawSubscores setObject:[NSNumber numberWithFloat:self.video.views.floatValue] forKey:@"viewCount"];
	NSLog(@"VIEW COUNT: %f", self.video.views.floatValue);
	
	// Relevance
	// TBD
	[self.rawSubscores setObject:[NSNumber numberWithInt:1] forKey:@"relevance"];
	NSLog(@"RELEVANCE: 1");
	
	// Was uploaded by entity's account
	// TBD
	
	// IMPORTANT: setup weighting array
	self.subscoreWeights = [NSMutableDictionary dictionaryWithCapacity:4];
	[self.subscoreWeights setObject:[NSNumber numberWithFloat:WEIGHTING_newness] forKey:@"newness"];
	[self.subscoreWeights setObject:[NSNumber numberWithFloat:WEIGHTING_viewcount] forKey:@"viewCount"];
	[self.subscoreWeights setObject:[NSNumber numberWithFloat:WEIGHTING_relevance] forKey:@"relevance"];
//	[self.subscoreWeights setObject:[NSNumber numberWithFloat:WEIGHTING_blah] forKey:@"uploadedByEntitysAccount"];

	NSLog(@"WEIGHTING Newness: %f", WEIGHTING_newness);
	NSLog(@"WEIGHTING View Count: %f", WEIGHTING_viewcount);
	NSLog(@"WEIGHTING Relevance: %f", WEIGHTING_relevance);
//	NSLog(@"WEIGHTING Newness: %f", WEIGHTING_newness);

	
}

@end
