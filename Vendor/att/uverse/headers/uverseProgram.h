//
//  uverseProgram.h
//
//  Created by Arnold Goldberg on 3/18/11.
//  Copyright 2011 AT&T Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*! \file uverseProgram.h
 */

/*! \enum uverseProgramType
 An enumeration of program types
 */
typedef enum
{
  UnknownProgramType, /** The program type is unknown */
  LiveTV,             /**< The program is live television */
  DVRSeries,          /**< The program is a DVR Series recording */
  DVRShow,            /**< The program is a DVR Show recording */
  StreamProgramType   /**< The program is Stream */
} uverseProgramType;

/*! \enum uverseDVRStatus
 An enumeration of DVR States
 */
typedef enum
{
  uverseDVRStatusUnknown, /**< The DVR Status is Unknown */
  uverseDVRStatusRecorded,   /**< The program is recorded on the DVR */
  uverseDVRStatusScheduled   /**< The program is scheduled to record on the DVR */
} uverseDVRStatus;

/*! \enum programDefinition
 An enumeration of program types
 */
typedef enum
{
  Unknown, /**< The program definition is unknown */
  SD,      /**< The program is Standard Definition */
  HD       /**< The program is High Definition */
} programDefinition;

//! This is a simple data class representing a program.
@interface uverseProgram : NSObject {
  
  NSString * title;
  int channel;
  int ref;
  NSDate * time;
  NSString * description;
  NSString * episode;
  NSString * duration;
  uverseProgramType type;
  NSString * tuneString;
  programDefinition definition;
  uverseDVRStatus dvrStatus;
    NSString *ratings;
}

/** Internal channel reference number used for tuning. */
@property (nonatomic, assign) int ref;
/** Channel number of the program. */
@property (nonatomic, assign) int channel;
/** Starting time (GMT) of the program, in ISO 8601 format. */
@property (nonatomic, retain) NSDate   * time;
/** Title of the program. */
@property (nonatomic, retain) NSString * title;
/** Program description. */
@property (nonatomic, retain) NSString * description;
/** Title of the Episode. */
@property (nonatomic, retain) NSString * episode;
/** Duration of the program in ISO 8601 format. */
@property (nonatomic, retain) NSString * duration;
/** String used for tuning to this program, only valid for recorded programs. */
@property (nonatomic, retain) NSString * tuneString;
/** Type of program (UnknownProgramType, LiveTV or DVR) */
@property (nonatomic, assign) uverseProgramType type;
/** Definition of program (Unknown, SD or HD) */
@property (nonatomic, assign) programDefinition definition;
/** DVR Status of the program (uverseDVRStatusUnknown, uverseDVRStatusRecorded or uverseDVRStatusScheduled) */
@property (nonatomic, assign) uverseDVRStatus dvrStatus;
/** Content ratings. */
@property (nonatomic, retain) NSString *ratings;

@end
