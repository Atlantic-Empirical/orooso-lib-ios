//
//  uveAnimationPan.h
//  DAIS
//
//  Created by Erik Smith on 8/12/11.
//  Copyright 2011 AT&T. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "uveAnimationStep.h"

/**
 uveAnimationPan represents a translation movement of an object on the screen. 
 If the object to be animated has the coordinates (x, y) then this
 animation will move object from (x+from, y+from) to  
 (x+from+deltaX, y+from+deltaY). This movement will occur over the time period specified by “duration”, which is system dependent, not in milliseconds or seconds. If loop is set to YES, the animation will repeat itself 
 continuously unless it is reset. if autoReverse is set to YES, the animation will be play and then play in reverse. 
 See uveAnimationStep for information about properties such as begin and index. The index value is used 
 when more than one animation step is used 
 so the animations can be sequenced.
 */
@interface uveAnimationPan : uveAnimationStep { }
/** Move object from position (x+from, y+from) to position (x+from+deltaX, y+from+deltaY) */
@property (nonatomic, assign) float from;
/** Move object from position (x+from, y+from) to position (x+from+deltaX, y+from+deltaY) */
@property (nonatomic, assign) float deltaX;
/** Move object from position (x+from, y+from) to position (x+from+deltaX, y+from+deltaY) */
@property (nonatomic, assign) float deltaY;
/** If true, the animation will be a back-and-forth animation. */
@property (nonatomic, assign) BOOL autoReverse;
/** If true, the animation will repeat continuously until reset. */
@property (nonatomic, assign) BOOL loop;

/**
 Initializes and returns a uveAnimationPan object. See class description for an explanation of parameters.
 */
- (id) initWithFrom:(float)from deltaX:(float)deltaX deltaY:(float)deltaY duration:(float)duration;
/**
 Initializes and returns a uveAnimationPan object. See class description for an explanation of parameters.
 */
- (id) initWithFrom:(float)from deltaX:(float)deltaX deltaY:(float)deltaY duration:(float)duration index:(int)index;


@end

