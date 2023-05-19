//
//  uveAnimationZoom.h
//  DAIS
//
//  Created by Erik Smith on 8/15/11.
//  Copyright 2011 AT&T. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uveAnimationStep.h"

/**
 uveAnimationZoom does a “scale and translate” effect to an object on the screen. 
 If the object that will be animated is at the coordinates (x, y) and has the dimensions 
 (width, height) then the animation will scale the object from the size 
 (width*startSizeXMultiplier, height*startSizeYMultiplier) with a scale center at (centerX, centerY) to the resulting size of 
 (width*endSizeXMultiplier, height*endSizeYMultiplier) for the time period specified by the "duration". 
 
 The centerPositionX and centerPositionY are relative to the current (x,y) position of the object. 
 
 See uveAnimationStep for properties like begin and index.
 The index value is used when more than one Zoom animation is specified in the 
 animation definition so the animations can be sequenced.
 The begin value represents the desired delay between the time of invocation of 
 the animation and the the actual time the animation starts.
 The duration is how long the transition will take to occur.
 */
@interface uveAnimationZoom : uveAnimationStep { }
@property (nonatomic, assign) float startWidthMultiplier;
@property (nonatomic, assign) float startHeightMultiplier;
@property (nonatomic, assign) float endWidthMultiplier;
@property (nonatomic, assign) float endHeightMultiplier;
@property (nonatomic, assign) float centerPositionX;
@property (nonatomic, assign) float centerPositionY;
@property (nonatomic, assign) BOOL  relative;

/**
 Initializes and returns a uveAnimationZoom object. See class description for an explanation of parameters.
 */
- (id) initWithStartWidthMultiplier:(float)startWidthMultiplier 
              startHeightMultiplier:(float)startHeightMultiplier
                 endWidthMultiplier:(float)endWidthMultiplier 
                endHeightMultiplier:(float)endHeightMultiplier
                        duration:(float)duration;

/**
 Initializes and returns a uveAnimationZoom object. See class description for an explanation of parameters.
 */
- (id) initWithStartWidthMultiplier:(float)startWidthMultiplier 
              startHeightMultiplier:(float)startHeightMultiplier
                 endWidthMultiplier:(float)endWidthMultiplier 
                endHeightMultiplier:(float)endHeightMultiplier 
                    centerPositionX:(float)centerPositionX 
                    centerPositionY:(float)centerPositionY
                           duration:(float)duration;

@end

