//
//  uveRemoteButtonCommand.h
//
//  Created by Chris Woodard on 5/2/11.
//  Copyright 2011 AT&T Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uveBaseCommand.h"
#import "RemoteKey.h"

//! Command object for sending a remote control command to the SetTopBox
/*!
 The uveRemoteButtonCommand is used to send a discrete remote control key, or alphanumeric character to the SetTopBox. 
 
 As with all SetTopBox commands this command is asynchronous. The success or failure is indicated
 by an NSNotification received when the command has completed. Success is indicated by receipt of a 
 NSNotification named #uveSetTopBoxCommandDidSucceed, whereas failure is indicated by receipt of an NSNotification
 named #uveSetTopBoxCommandDidFail.
 */
@interface uveRemoteButtonCommand : uveBaseCommand {
}

/** 
 Initializes and returns a newly allocated uveRemoteButtonCommand object with a discrete remote control key. 
 @param key The discrete remote control key to send to the SetTopBox. See the #RemoteKey enumeration for supported values.  
 @returns An initialized uveRemoteButtonCommand object or nil if the object couldn't be created.
 */
-(id)initWithRemoteKey:(RemoteKey)key;
/** 
 Initializes and returns a newly allocated uveRemoteButtonCommand object with a alphanumeric character. 
 @param ch An alphanumeric character to send to the SetTopBox. Used in places where a alpha-numeric keyboard is displayed by the SetTopBox, search for example.  
 @returns An initialized uveRemoteButtonCommand object or nil if the object couldn't be created.
 */
-(id)initWithRemoteKeyChar:(unichar)ch;

@end
