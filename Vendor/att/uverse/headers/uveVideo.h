//
//  uveVideo.h
//  DAIS
//
//  Created by Erik Smith on 8/1/11.
//  Copyright 2011 AT&T. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "uveGadget.h"
#include "uveAction.h"
#include "uveActionContainer.h"

/**
 Displays a video on the uvePage.
 */
@interface uveVideo : uveGadget { }
/** The action to be invoked when the last associated media item ( there may be a group ) ends. */
@property (nonatomic, retain) uveAction* onMediaEnd;
/** The action to be invoked when a fatal media error occurs during playback or tuning. */
@property (nonatomic, retain) uveAction* onMediaError;
/** The action to be invoked when the media reaches the end of its stream. This event does not occur when the stop button is pressed. If there is a group of media being played, this event will only occur when the entire group has been played. */
@property (nonatomic, retain) uveAction* onMediaItemEnd;
/** The action to be invoked when a media item begins to play. */
@property (nonatomic, retain) uveAction* onMediaPlay;
/** The action to be invoked when a media item begins to play. */
@property (nonatomic, retain) uveAction* onMediaStart;
/** The action to be invoked when the media being played is prematurely stopped. */
@property (nonatomic, retain) uveAction* onMediaStop;
/** This action will occur when the beginning of a clip is crossed at a negative play speed (e.g. rewind). */
@property (nonatomic, retain) uveAction* onMediaClipBegin;
/** This action will occur when the beginning of a is crossed at a positive play speed (e.g. play, fast-forward). */
@property (nonatomic, retain) uveAction* onMediaClipEnd;
/** Displays feedback when activity is occuring. Defaults to YES. */
@property (nonatomic, assign) BOOL showBusyIndicator;
/** Dictates whether or not the uveVideo object is in picture-in-picture mode. */
@property (nonatomic, assign) BOOL pictureInPicture;
/** The channel to which the uveVideo object will be tuned. */
@property (nonatomic, assign) unsigned int channel;
/** The call letters to which the uveVideo object will be tuned, such as CNN. */
@property (nonatomic, retain) NSString *callLetters;
/** The URL to which the uveVideo object will be tuned. */
@property (nonatomic, retain) NSURL *tuneURL;
/** YES will cause the this uveVideo object to detune. NO by default. */
@property (nonatomic, assign) BOOL detune;


/**
 Initializes the uveVideo object.
 @returns The initialized object.
 */
- (id)init;

/**
 Initializes the uveVideo object.
 @param name An identifier for the object.
 @returns The initialized object.
 */
- (id)initVideoWithName:(NSString*)name;


/**
 Initializes the uveVideo object.
 @param name An identifier for the object.
 @param channel The numeric channel to which the video control will be tuned.
 @param frame The coordinates of the upper left corner of the control and its dimensions.
 @returns The initialized object.
 */
- (id)initVideoWithName:(NSString*)name channel:(unsigned int)channel frame:(CGRect)frame;


/**
 Initializes the uveVideo object.
 @param name An identifier for the object.
 @param callLetters The call letters of the channel to which the video conrol will be tuned.
 @param frame The coordinates of the upper left corner of the control and its dimensions.
 @returns The initialized object.
 */
- (id)initVideoWithName:(NSString*)name callLetters:(NSString*)callLetters frame:(CGRect)frame;

/**
 Initializes the uveVideo object. An empty URL will thrown an exception.
 @param name An identifier for the object.
 @param tuneURL The URL of the resource to which the video control will be tuned.
 @param frame The coordinates of the upper left corner of the control and its dimensions.
 @returns The initialized object.
 */
- (id)initVideoWithName:(NSString*)name tuneURL:(NSURL*)tuneURL frame:(CGRect)frame;


@end
