//
//  uveActionRefresh.h
//  DAIS
//
//  Created by Erik Smith on 4/2/12.
//  Copyright (c) 2012 AT&T. All rights reserved.
//

#import "uveAction.h"

/**
 Refreshes the data source.
*/
@interface uveActionRefresh : uveAction

/** Forces the refresh to bypass the cache. Defaults to false. */
@property (nonatomic, assign) BOOL force; 

/**
 Initializes the action.
 @param name The name of this action. This can be nil if the action is being placed inside of a uveActionContainer or if the setName property is used instead.
 @param targetControlName The name of the control to be affected.
 @returns The initialized uveActionRefresh object.
 */
- (id) initActionWithName:(NSString*)name
      nameOfTargetControl:(NSString*)targetControlName;

/**
 Initializes the action.
 @param name The name of this action. This can be nil if the action is being placed inside of a uveActionContainer or if the setName property is used instead.
 @param targetControlNames The names of the controls to be affected. NSSet of NSString.
 @returns The initialized uveActionRefresh object.
 */
- (id) initActionWithName:(NSString*)name
    namesOfTargetControls:(NSSet*)targetControlNames;

@end

