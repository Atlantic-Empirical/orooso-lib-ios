//
//  uveTuneToURLCommand.h
//
//  Created by Arnold Goldberg on 5/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uveBaseCommand.h"

//! Command object for tuning the SetTopBox to a URL
/*!
 The uveTuneToURLCommand is used for opening a supported URL on the SetTopBox. 
 
 As with all SetTopBox commands this command is asynchronous. The success or failure is indicated
 by an NSNotification received when the command has completed. Success is indicated by receipt of a 
 NSNotification named #uveSetTopBoxCommandDidSucceed, whereas failure is indicated by receipt of an NSNotification
 named #uveSetTopBoxCommandDidFail.
 */
@interface uveTuneToURLCommand : uveBaseCommand {
    
}
/** 
  Initializes and returns a newly allocated uveTuneToURLCommand object with the specified URL. 
  @param url The URL that this command will attempt to tune the SetTopBox to.  
  @returns An initialized uveTuneToURLCommand object or nil if the object couldn't be created.
 */
-(id)initWithURL:(NSString *)url;

@end
