//
//  uveMediaProfile.h
//  DAIS
//
//  Created by Erik Smith on 4/3/12.
//  Copyright (c) 2012 AT&T. All rights reserved.
//

#import "uveNode.h"

/** Manages video streams. */
@interface uveMediaProfile : uveNode

/** Indicates if the stream is needed. Default is NO. */
@property (nonatomic, assign) BOOL liveHD;
/** Indicates if the stream is needed. Default is NO. */
@property (nonatomic, assign) BOOL liveSD;
/** Indicates if the stream is needed. Default is NO. */
@property (nonatomic, assign) BOOL vodHD;
/** Indicates if the stream is needed. Default is NO. */
@property (nonatomic, assign) BOOL vodSD;
/** Indicates if the stream is needed. Default is NO. */
@property (nonatomic, assign) BOOL dvrPlaybackHD;
/** Indicates if the stream is needed. Default is NO. */
@property (nonatomic, assign) BOOL dvrPlaybackSD;
/** Indicates if the stream is needed. Default is NO. */
@property (nonatomic, assign) BOOL dvrRecordHD;
/** Indicates if the stream is needed. Default is NO. */
@property (nonatomic, assign) BOOL dvrRecordSD;
/** Indicates the number of pip streams needed. Range is 0 to 6, inclusive. Zero is default. */
@property (nonatomic, assign) unsigned short numberOfPIPs;
/** Indicates the bit rate in bytes. Zero is default. */
@property (nonatomic, assign) unsigned int wmBitrate;
/** Prevents a video stream from being stolen. Default is NO. */
@property (nonatomic, assign) BOOL useApplicationPriority;

/**
 Initializes the object.
 @returns The initialized object.
 */
- (id) init;


/**
 Initializes the object.
 @param name An identifier for the uveMediaProfile object.
 @returns The initialized object.
 */
- (id) initMediaProfileWithName:(NSString*)name;


/**
 Initializes the object.
 @param name An identifier for the uveMediaProfile object.
 @param liveHD Indicates if the stream is needed. 
 @param liveSD Indicates if the stream is needed. 
 @param vodHD Indicates if the stream is needed. 
 @param vodSD Indicates if the stream is needed. 
 @param dvrPlaybackHD Indicates if the stream is needed. 
 @param dvrPlaybackSD Indicates if the stream is needed. 
 @param dvrRecordHD Indicates if the stream is needed. 
 @param dvrRecordSD Indicates if the stream is needed.
 @param useApplicationPriority Prevents a video stream from being stolen.
 @param numberOfPIPs Indicates the number of pip streams needed. Range is 0 to 6, inclusive. 
 @param wmBitrate Indicates the bit rate in bytes. 
 @returns The initialized object.
 */
- (id) initMediaProfileWithName:(NSString*)name
                         liveHD:(BOOL)liveHD
                         liveSD:(BOOL)liveSD
                          vodHD:(BOOL)vodHD
                          vodSD:(BOOL)vodSD
                  dvrPlaybackHD:(BOOL)dvrPlaybackHD
                  dvrPlaybackSD:(BOOL)dvrPlaybackSD
                    dvrRecordHD:(BOOL)dvrRecordHD
                    dvrRecordSD:(BOOL)dvrRecordSD
         useApplicationPriority:(BOOL)useApplicationPriority
                   numberOfPIPs:(unsigned short)numberOfPIPs
                      wmBitrate:(unsigned int)wmBitrate;

@end
