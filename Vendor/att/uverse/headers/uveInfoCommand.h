//
//  uveInfoCommand.h
//
//  Created by Arnold Goldberg on 5/10/11.
//  Copyright 2011 AT&T Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uveBaseCommand.h"
#import "uverseProgram.h"

//! Command object for obtaining information regarding the program currently playing on the SetTopBox.
/*!
 The uveInfoCommand is used to refresh the currentProgram information on the SetTopBox. 
 
 This command is used internally automatically whenever a program changes, or the channel changes. Typically
 a developer should not have to exercise this command.
 
 As with all SetTopBox commands this command is asynchronous. The success or failure is indicated
 by an NSNotification received when the command has completed. Success is indicated by receipt of a 
 NSNotification named #uveSetTopBoxCommandDidSucceed, whereas failure is indicated by receipt of an NSNotification
 named #uveSetTopBoxCommandDidFail.
 
 On successful completion of this command, the developer may access the program property to get current
 program information.
 */
@interface uveInfoCommand : uveBaseCommand {
    
}
/**
 The program the SetTopBox is currently tuned to.
 */
@property (nonatomic, retain) uverseProgram * program;
@end
