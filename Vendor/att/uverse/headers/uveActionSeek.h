//
//  uveActionSeek.h
//  DAIS
//
//  Created by Erik Smith on 9/13/11.
//  Copyright 2011 AT&T. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uveAction.h"

/**
 Seeks the stream the specified number of seconds.
  If using as a single action outside of a uveActionContainer set the name property inherited from uveNode.
 */
@interface uveActionSeek : uveAction { }

/** The number of seconds to seek. This may be positive or negative. */
@property (nonatomic, assign) int seconds;

/**
Seeks the stream the specified number of seconds. Use the seconds parameter to specify the number of 
 seconds to seek.
 
 Not all streams types support seeking. For uveActionSeek to operate on Windows Media streams, they 
 must be streamed from a Streaming Media Server. There may be a delay when seeking to a new location. 
 PIPs may not support seeking. The uveActionSeek will be ignored if the stream type does not support seeking. In the case where there is more than one program in a playlist, seeking will be limited to the end of the current program.  
 @param name The name of this action. This can be nil if the action is being placed inside of a uveActionContainer or if the setName property is used, instead.
 @param targetControlName The name of the control to be affected.
 @param seconds The number of seconds to seek. This may be positive or negative.
 @returns The initialized uveActionSeek object.
 */
- (id) initActionWithName:(NSString*)name
      nameOfTargetControl:(NSString*)targetControlName
                  seconds:(int)seconds;


@end

