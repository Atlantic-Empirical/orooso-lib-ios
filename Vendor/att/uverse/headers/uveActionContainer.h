//
//  uveActionContainer.h
//  DAIS
//
//  Created by Erik Smith on 11/4/11.
//  Copyright 2011 AT&T. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uveAction.h"

/**
This class is used for the sole purpose of containing one or more uveAction(s). The container has a name which is used by events to invoke all the actions contained within the uveActionContainer object. 
 */
@interface uveActionContainer : uveAction { }


/**
 Initializes the uveActionContainer object with a name.
 @param name An identifier for the uveActionContainer object.
 @returns returns the intialized object.
 */
- (id) initWithName:(NSString *)name;
/**
 Adds a uveAction-derived object to this action container.
 @param action The action to be added to the container. Another uveActionContainer can be passed in and its actions will be retained.
 */
- (void) addAction:(uveAction *)action;



@end
