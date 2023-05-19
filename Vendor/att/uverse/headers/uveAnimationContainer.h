//
//  uveAnimationContainer.h
//  DAIS
//
//  Created by Erik Smith on 10/18/11.
//  Copyright 2011 AT&T. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "uveNode.h"
#import "uveAnimationStep.h"


/**
 Any instance of a class that is derived from uveAnimationStep
 may be added to this container. Examples: uveAnimationFade, uveAnimationPan,
 uveAnimationZoom. These uveAnimationStep-derived classes may be indexed to allow multiple animations to be 
 enacted in sequence by refering only to the uveAnimationContainer name. After all the necessary objects have been added to a uveAnimationContainer object, that uveAnimationContainer object is then added to the uvePage.
 */
@interface uveAnimationContainer : uveNode {}

/**
 Initializes the uveAnimation object.
 @param name An identifier for the uveAnimation object.
 @returns returns the intialized object.
 */
- (id) initWithName:(NSString *)name;
/**
 Adds a uveAnimationStep object to this animation container.
 @param animationStep Could be of type uveAnimationFade, uveAnimationPan,
 uveAnimationZoom
 */
- (void) addAnimationStep:(uveAnimationStep *)animationStep;
@end
