//
//  uveActionShow.h
//  DAIS
//
//  Created by Erik Smith on 9/27/11.
//  Copyright 2011 AT&T. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uveAction.h"

/**
 Shows the control with the name that is specified by the target. 
  If using as a single action outside of a uveActionContainer set the name property inherited from uveNode.
*/
@interface uveActionShow : uveAction { }

/**
 Shows the control with the name that is specified by the target. 
 @param name The name of this action. This can be nil if the action is being placed inside of a uveActionContainer or if the setName property is used, instead.
 @param targetControlName The name of the control to be affected.
 @returns The initialized uveActionShow object.
 */
- (id) initActionWithName:(NSString*)name
      nameOfTargetControl:(NSString*)targetControlName;

/**
 Shows the list of controls with names that are specified by the targetControlNames list. 
 @param name The name of this action. This can be nil if the action is being placed inside of a uveActionContainer or if the setName property is used, instead.
 @param targetControlNames The names of the controls to be affected. NSArray of NSString.
 @returns The initialized uveActionShow object.
 */
- (id) initActionWithName:(NSString*)name
    namesOfTargetControls:(NSSet*)targetControlNames;


@end

