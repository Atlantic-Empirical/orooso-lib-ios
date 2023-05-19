//
//  uveActionCustom.h
//  DAIS
//
//  Created by Erik Smith on 11/30/11.
//  Copyright 2011 AT&T. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uveAction.h"

/**
 This class provides the ability to add an action that responds to a cusom event. The event name should not contain punctuation.
 */
@interface uveActionCustom : uveAction { }

/** The name of the custom event to be associated with this action. */
@property (nonatomic, retain) NSString* customEventName;


/** Data to be provided to the custom event being called. */
@property (nonatomic, retain) NSString* data;

/** 
 Returns an initialized uveActionCustom object.
 @param name The name of this action.
 @param customEventName The name used for the custom event to be invoked by this action. The event name should not contain punctuation.
 @param data Data to be provided to the custom event being called.
 */
- (id) initActionWithName:(NSString*)name
          customEventName:(NSString*)customEventName
                     data:(NSString*)data;

@end
