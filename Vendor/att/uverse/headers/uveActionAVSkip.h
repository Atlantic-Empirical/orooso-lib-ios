//
//  uveActionAVSkip.h
//  DAIS
//
//  Created by Erik Smith on 9/12/11.
//  Copyright 2011 AT&T. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uveAction.h"

/**
 Skips forward or backward in the stream.
  If using as a single action outside of a uveActionContainer set the name property inherited from uveNode.
 */
@interface uveActionAVSkip : uveAction { }

/** The number of seconds to skip. This may be positive or negative. */
@property (nonatomic, assign) int seconds;

/**
 Skips forward or backward in the stream (typically, a video stream) in the specified direction 
 or by a specified number of seconds. If 
 the stream does not support specifying seconds, the behavior is based on the sign of the 
 number: + for forward, – for backwards. This will throw an exception if nil parameters are given.
 @param name The name of this action. This can be nil if the action is being placed inside of a uveActionContainer or if the setName property is used, instead.
 @param targetControlName The name of the control to be affected.
 @param seconds The number of seconds to skip. This may be positive or negative.
 @returns The initialized uveActionSkip object.
 */
- (id) initActionWithName:(NSString*)name
      nameOfTargetControl:(NSString*)targetControlName
                  seconds:(int)seconds;


@end

