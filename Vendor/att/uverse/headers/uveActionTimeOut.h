//
//  uveActionTimeOut.h
//  DAIS
//
//  Created by Erik Smith on 9/13/11.
//  Copyright 2011 AT&T. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uveAction.h"

/**
 This performs an action at a later time.
  If using as a single action outside of a uveActionContainer set the name property inherited from uveNode.
 */
@interface uveActionTimeOut : uveAction { }

/** The name of the action to be invoked after the delay. */
@property (nonatomic, retain) NSString* actionToInvoke;
/** This is an arbitrary string used to signal an in-progress uveActionTimeOut to stop. If omitted, the action cannot be canceled or replaced. */
@property (nonatomic, retain) NSString* cancelationName;
/** Delay in milliseconds before the action is performed. Not a 
 guaranteed delay. There may be a minimum delay to which this value will be 
 added. This value can be zero. */
@property (nonatomic, assign) unsigned int millisecondsDelay;

/**
 Performs an action at a later time. This can be used when an 
 action should be performed after a specified duration. Add the action to be performed at a later time to the the containing uvePage. 
 @param name The name of this action. This can be nil if the action is being placed inside of a uveActionContainer or if the setName property is used, instead.
 @param targetControlName The name of the control to be affected.
 @param actionToInvoke The name of the action to be invoked after the delay.
 @param cancelationName This is an arbitrary string used to signal an in-progress uveActionTimeOut to stop. If omitted, the action cannot be canceled or replaced. To use this create an initial uveActionTimeOut object with an aribitrary cancelationName then, create another uveActionTimeOut object with the same cancelationName and the same targetControlName that can be triggered by another event
 @param millisecondsDelay Delay in milliseconds before the action is performed. Not a 
 guaranteed delay. There may be a minimum delay to which this value will be 
 added. This value can be zero.

 @returns The initialized uveActionTimeOut object.
 */
- (id) initActionWithName:(NSString*)name
        targetControlName:(NSString*)targetControlName
           actionToInvoke:(NSString*)actionToInvoke
          cancelationName:(NSString*)cancelationName
        millisecondsDelay:(unsigned int)millisecondsDelay;


@end


