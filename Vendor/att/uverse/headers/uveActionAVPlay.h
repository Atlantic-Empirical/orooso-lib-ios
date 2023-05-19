//
//  uveActionAVPlay.h
//  DAIS
//
//  Created by Erik Smith on 9/12/11.
//  Copyright 2011 AT&T. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uveAction.h"




/*! \file uveActionAVPlay.h
 */

/*! \enum AVPlayActionSpeedType
 The higher the number the faster the play speed. kForward1 is normal play speed.
  If using as a single action outside of a uveActionContainer set the name property inherited from uveNode.
 Available values:
 kRewind4,
 kRewind3,
 kRewind2,
 kRewind1,
 kPause,
 kForward1,
 kForward2,
 kForward3,
 kForward4
 */
typedef enum 
{
    kRewind4,
    kRewind3,
    kRewind2,
    kRewind1,
    kPause,
    kForward1,
    kForward2,
    kForward3,
    kForward4,
} AVPlayActionSpeedType;

/**
 Changes the stream playback speed.
 */
@interface uveActionAVPlay : uveAction { }

/** The speed and direction of play on the video stream. The higher the number the faster the play. kForward1 is normal play speed. */
@property(nonatomic, assign) AVPlayActionSpeedType playSpeed;

/**
 Changes the stream (typically, a video stream) playback speed. This action is ignored if the target control 
 does not have media currently playing. 
 @param name The name of this action. This can be nil if the action is being placed inside of a uveActionContainer or if the setName property is used, instead.
 @param targetControlName The name of the control to be affected.
 @param playSpeed The speed and direction of play on the video stream. The higher the number the faster the play. kForward1 is normal play speed.
 @returns The initialized uveActionAVPlay object.
 */
- (id) initActionWithName:(NSString*)name
      nameOfTargetControl:(NSString*)targetControlName
                playSpeed:(AVPlayActionSpeedType)playSpeed;


@end
