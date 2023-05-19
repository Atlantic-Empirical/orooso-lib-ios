//
//  uveTuneToChannelNumberCommand.h
//
//  Created by Chris Woodard on 5/2/11.
//  Copyright 2011 AT&T Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uveBaseCommand.h"

//! Command object for tuning a SetTopBox to a particular channel using the channel number
/*!
 The uveTuneToChannelNumberCommand is used to tune the SetTopBox to a particular channel using the channel number. 
 
 As with all SetTopBox commands this command is asynchronous. The success or failure is indicated
 by an NSNotification received when the command has completed. Success is indicated by receipt of a 
 NSNotification named #uveSetTopBoxCommandDidSucceed, whereas failure is indicated by receipt of an NSNotification
 named #uveSetTopBoxCommandDidFail.
 */
@interface uveTuneToChannelNumberCommand : uveBaseCommand {
}
/** 
 Initializes and returns a newly allocated uveTuneToChannelNumberCommand object with the specified channel number. 
 @param channelNum The channel number that this command will attempt to tune the SetTopBox to.  
 @returns An initialized uveTuneToChannelNumberCommand object or nil if the object couldn't be created.
 */
-(id)initWithChannelNumber:(NSInteger)channelNum;

@end
