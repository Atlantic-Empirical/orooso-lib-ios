//
//  uveAnimationStep.h
//  DAIS
//
//  Created by Erik Smith on 8/15/11.
//  Copyright 2011 AT&T. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "uveNode.h"


/**
 uveAnimationStep should be considered abstract. uveAnimationFade,
 uveAnimationPan, uveAnimationZoom inherit from this class.
 */
@interface uveAnimationStep : uveNode { }
/** The interval after which the animation begins. System dependent, not milliseconds or seconds. */
@property (nonatomic, assign) float begin;
/** The duration of the animation. System dependent, not milliseconds or seconds. */
@property (nonatomic, assign) float duration;
/** The index of the animation. Used for sequencing when there is more than one animation step. Must be zero or greater. */
@property (nonatomic, assign) int index;




@end

