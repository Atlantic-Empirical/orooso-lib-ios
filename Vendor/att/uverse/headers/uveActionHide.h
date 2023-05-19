//
//  uveActionHide.h
//  DAIS
//
//  Created by Erik Smith on 9/13/11.
//  Copyright 2011 AT&T. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uveAction.h"

/**
 Hides the control with the name that is specified as the target.
  If using as a single action outside of a uveActionContainer set the name property inherited from uveNode.
*/
@interface uveActionHide : uveAction { }


/**
 Hides the control with the name that is specified as the target. 
 @param name The name of this action. This can be nil if the action is being placed inside of a uveActionContainer or if the setName property is used, instead.
 @param targetControlName The name of the control to be affected.
 @returns The initialized uveActionHide object.
 */
- (id) initActionWithName:(NSString*)name
      nameOfTargetControl:(NSString*)targetControlName;

/**
 Hides the list of controls with names that are specified by the targetControlNames list. 
 @param name The name of this action. This can be nil if the action is being placed inside of a uveActionContainer or if the setName property is used, instead.
 @param targetControlNames The names of the controls to be affected. NSArray of NSString.
 @returns The initialized uveActionHide object.
 */
- (id) initActionWithName:(NSString*)name
    namesOfTargetControls:(NSSet*)targetControlNames;


@end

