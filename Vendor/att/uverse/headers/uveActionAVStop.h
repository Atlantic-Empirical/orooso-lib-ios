//
//  uveActionAVStop.h
//  DAIS
//
//  Created by Erik Smith on 9/12/11.
//  Copyright 2011 AT&T. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uveAction.h"

/**
 Stops the stream and sets the stream back to the beginning.
  If using as a single action outside of a uveActionContainer set the name property inherited from uveNode.
 */
@interface uveActionAVStop : uveAction { }

/**
 Stops the stream and sets the stream back to the beginning. The target for the action is a 
 video control or the special name UVEFULLSCREEN, which is used to control the video on the 
 full-screen. Actions will be performed if they are assigned to onMediaStop on the uveVideo object.
 @param name The name of this action. This can be nil if the action is being placed inside of a uveActionContainer or if the setName property is used, instead.
 @param targetControlName The name of the control to be affected.
 @returns The initialized uveActionStop object.
 */
- (id) initActionWithName:(NSString*)name
      nameOfTargetControl:(NSString*)targetControlName;


@end

