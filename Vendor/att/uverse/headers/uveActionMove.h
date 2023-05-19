//
//  uveActionMove.h
//  DAIS
//
//  Created by Erik Smith on 9/13/11.
//  Copyright 2011 AT&T. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uveAction.h"
#import <CoreGraphics/CGGeometry.h>

/**
 Moves the target control and allows for resizing.
  If using as a single action outside of a uveActionContainer set the name property inherited from uveNode.
 */
@interface uveActionMove : uveAction { }

/** The new position and dimensions of the target control. */
@property (nonatomic, assign) CGRect frame;

/**
    Moves the target control and and allows for resizing. The x and y coordinates are used to 
    specify the destination to move the target control to. The width and height are the final size 
    of the target control. This is a single-target action. 
    @param name The name of this action. This can be nil if the action is being placed inside of a uveActionContainer or if the setName property is used, instead.
    @param targetControlName The name of the control to be affected.
    @param frame The new position and dimensions of the target control.
    @returns The initialized uveActionMove object.
*/
- (id) initActionWithName:(NSString*)name
      nameOfTargetControl:(NSString*)targetControlName
                    frame:(CGRect)frame;



@end
