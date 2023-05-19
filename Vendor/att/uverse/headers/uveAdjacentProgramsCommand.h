//
//  uveAdjacentProgramsCommand.h
//  DAIS
//
//  Created by Arnold Goldberg on 9/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "uveBaseCommand.h"
#import "uverseProgram.h"

//! Command object for requesting the program information for the previous, current, and next channel
/*!
 The uveAdjacentProgramsCommand is used to request the program information for the previous, current, and next channel
 
 As with all SetTopBox commands this command is asynchronous. The success or failure is indicated
 by an NSNotification received when the command has completed. Success is indicated by receipt of a 
 NSNotification named #uveSetTopBoxCommandDidSucceed, whereas failure is indicated by receipt of an NSNotification
 named #uveSetTopBoxCommandDidFail.
 */
@interface uveAdjacentProgramsCommand : uveBaseCommand <NSXMLParserDelegate>

/**
 A uverseProgram object reprenseting the program airing on the previous channel in the channel lineup.
 */
@property (nonatomic, retain) uverseProgram * previousChannelProgram;
/**
 A uverseProgram object reprenseting the currently tuned program.
 */
@property (nonatomic, retain) uverseProgram * currentProgram;
/**
 A uverseProgram object reprenseting the program airing on the next channel in the channel lineup.
 */
@property (nonatomic, retain) uverseProgram * nextChannelProgram;
@end
