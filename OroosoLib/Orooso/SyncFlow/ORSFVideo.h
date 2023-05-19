//
//  ORSFVideo.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 11/01/2013.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFItem.h"
#import "ISO8601DateFormatter.h"
#import "ORHourMinuteSecond.h"
#import "SORelativeDateTransformer.h"

typedef enum _SFVideoSource {
    SFVideoSourceYouTubeVideo,
    SFVideoSourceYouTubeLive,
    SFVideoSourceVimeoVideo,
    SFVideoSourceTVNZ
} SFVideoSource;

@class ORYouTubeVideo, ORYouTubeLiveEvent, ORVimeoVideo, ORTVNZArticle;

@interface ORSFVideo : ORSFItem

- (id)initWithYouTubeVideo:(ORYouTubeVideo *)video andEntity:(OREntity*)entity;
- (id)initWithYouTubeLiveEvent:(ORYouTubeLiveEvent *)video andEntity:(OREntity*)entity;
- (id)initWithVimeoVideo:(ORVimeoVideo *)video andEntity:(OREntity*)entity;
- (id)initWithTVNZArticle:(ORTVNZArticle *)video andEntity:(OREntity*)entity;
- (id)initWithORURL:(ORURL *)url andEntity:(OREntity*)entity;

@property (nonatomic, assign) SFVideoSource source;
@property (nonatomic, strong) ORYouTubeVideo *video;
@property (nonatomic, strong) ORYouTubeLiveEvent *event;
@property (nonatomic, strong) ORVimeoVideo *vimeoVideo;
@property (nonatomic, strong) ORTVNZArticle *tvnzVideo;

@end
