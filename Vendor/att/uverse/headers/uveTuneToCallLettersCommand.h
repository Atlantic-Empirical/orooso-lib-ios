//
//  uveTuneToCallLettersCommand.h
//
//  Created by Chris Woodard on 5/2/11.
//  Copyright 2011 AT&T Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uveBaseCommand.h"

//! Command object for tuning the SetTopBox to a channel using call letters
/*!
 The uveTuneToCallLettersCommand is used to tune the SetTopBox to a particular channel using call letters. 
 
 As with all SetTopBox commands this command is asynchronous. The success or failure is indicated
 by an NSNotification received when the command has completed. Success is indicated by receipt of a 
 NSNotification named #uveSetTopBoxCommandDidSucceed, whereas failure is indicated by receipt of an NSNotification
 named #uveSetTopBoxCommandDidFail.
 */
@interface uveTuneToCallLettersCommand : uveBaseCommand {
}

/** 
 Initializes and returns a newly allocated uveTuneToCallLettersCommand object with the call letters. 
 @param callLetters The call letters for the channel that this command will attempt to tune the SetTopBox to.  
 @returns An initialized uveTuneToCallLettersCommand object or nil if the object couldn't be created.
 */
-(id)initWithCallLetters:(NSString *)callLetters;

@end
