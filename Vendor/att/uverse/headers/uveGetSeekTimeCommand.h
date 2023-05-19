//
//  uveGetCurrentProgramSeekTimeCommand.h
//  DAIS
//
//  Created by Arnold Goldberg on 9/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "uveBaseCommand.h"

//! Command object for requesting the seek time into the currently playing DVR or VoD program.
/*!
 The uveGetSeekTimeCommand is used to request the seek time into the currently playing program. 
 
 Note: This command only works with VoD or DVR content. Attempts to get a seek time for Live TV will 
 return an error of #uveCommandDoesNotWorkWithLiveTV.
 
 As with all SetTopBox commands this command is asynchronous. The success or failure is indicated
 by an NSNotification received when the command has completed. Success is indicated by receipt of a 
 NSNotification named #uveSetTopBoxCommandDidSucceed, whereas failure is indicated by receipt of an NSNotification
 named #uveSetTopBoxCommandDidFail.
 */
@interface uveGetSeekTimeCommand : uveBaseCommand <NSXMLParserDelegate>
{
  NSString * seekTime;
}
/** The seek time into the current VoD or DVR program. */
@property(nonatomic, retain) NSString * seekTime;

@end
