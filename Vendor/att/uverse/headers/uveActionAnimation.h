//
//  uveActionAnimation.h
//  DAIS
//
//  Created by Erik Smith on 9/12/11.
//  Copyright 2011 AT&T. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uveAction.h"

/**
 Connects a specified animation to a specific event on a control. 
 The following animation types are supported: 
 - Fade 
 - Pan 
 - Zoom 
 See uveAnimationFade, uveAnimationPan, uveAnimationZoom, respectively.
 If using as a single action outside of a uveActionContainer set the name property inherited from uveNode.
*/
@interface uveActionAnimation : uveAction { }

/** The name of the uveAnimationContainer object that holds the animation steps to be performed. */
@property (nonatomic, retain) NSString* animationName;


/**
    Initializer. This will throw an exception if nil parameters are given.
    @param name The name of this action. This can be nil if the action is being placed inside of a uveActionContainer or if the setName property is used, instead.
	@param targetControlName The name of the control to be animated.
	@param animationName The name of the uveAnimation container object that holds the animation steps to be performed.
	@returns The initialized uveActionAnimation object.
 */
- (id) initActionWithName:(NSString*)name
      nameOfTargetControl:(NSString*)targetControlName
            animationName:(NSString*)animationName;

@end
