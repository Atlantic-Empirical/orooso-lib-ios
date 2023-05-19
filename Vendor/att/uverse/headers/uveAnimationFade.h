//
//  uveAnimationFade.h
//  DAIS
//
//  Created by Erik Smith on 8/15/11.
//  Copyright 2011 AT&T. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "uveNode.h"
#import "uveAnimationStep.h"

/**
 uveAnimationFade performs a “fade” effect on the target object. If the object to 
 be animated has alpha set to X then this animation transitions 
 the object transparency from (X*startAlphaMultiplier) to (X*endAlphaMultiplier) 
 where the transition will occur over the "duration" period of time. Duration is defined in a system-dependent manner. The index value is used when more than one animation is 
 specified in the uveAnimation object so the animations can be sequenced.  
 The begin value represents the delay between the time of invocation of 
 the animation and the the actual time the animation starts. Begin is defined in a system-dependent manner.
 See uveAnimationStep for inherited properties such as begin and index.
 */
@interface uveAnimationFade : uveAnimationStep { }
/** A value between 0 and 1, inclusive. 0 is transparent, 1 is fully visible. */
@property (nonatomic, assign) float startAlphaMultiplier;
/** A value between 0 and 1, inclusive. 0 is transparent, 1 is fully visible. */
@property (nonatomic, assign) float endAlphaMultiplier;

/**
 Initializes the uveAnimationFade object.
 @param startAlphaMultiplier A value between 0 and 1, inclusive. 0 is transparent, 1 is fully visible.
 @param endAlphaMultiplier A value between 0 and 1, inclusive. 0 is transparent, 1 is fully visible.
 @param duration Time duration.
 @returns The initialized uveAnimationFade object.
 */
- (id) initWithStartAlphaMultiplier:(float)startAlphaMultiplier 
                 endAlphaMultiplier:(float)endAlphaMultiplier 
                           duration:(float)duration;
/**
 Initializes the uveAnimationFade object.
 @param startAlphaMultiplier A value between 0 and 1, inclusive. 0 is transparent, 1 is fully visible.
 @param endAlphaMultiplier A value between 0 and 1, inclusive. 0 is transparent, 1 is fully visible.
 @param duration Time duration.
 @param index If in a group, this is the index in the sequence.
 @returns The initialized uveAnimationFade object.
 */
- (id) initWithStartAlphaMultiplier:(float)startAlphaMultiplier 
                 endAlphaMultiplier:(float)endAlphaMultiplier 
                           duration:(float)duration 
                              index:(int)index;

@end



