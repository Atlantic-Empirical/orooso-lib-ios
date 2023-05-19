//
//  uveActionFocus.h
//  DAIS
//
//  Created by Erik Smith on 9/13/11.
//  Copyright 2011 AT&T. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uveAction.h"

/**
 Sets the focus to a control in the page.
  If using as a single action outside of a uveActionContainer set the name property inherited from uveNode.
 */
@interface uveActionFocus : uveAction { }

/**
 Sets the focus to a control in the page, provided the control supports key input.  
 The focused object is the one that accepts input from the remote control. 
@param name The name of this action. This can be nil if the action is being placed inside of a uveActionContainer or if the setName property is used, instead.
@param targetControlName The name of the control to be affected.
@returns The initialized uveActionFocus object.
*/
- (id) initActionWithName:(NSString*)name
      nameOfTargetControl:(NSString*)targetControlName;

@end

