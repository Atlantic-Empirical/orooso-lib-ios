//
//  uveBusyIndicator.h
//  DAIS
//
//  Created by Erik Smith on 4/3/12.
//  Copyright (c) 2012 AT&T. All rights reserved.
//

#import "uveGadget.h"

/** Indicates navigation is occuring. */
@interface uveBusyIndicator : uveGadget { }

/**
 Initializes the object.
 @returns The initialized object.
 */
- (id) init;

/**
 Initializes the object.
 @param name An identifier for the uveBusyIndicator object.
 @returns The initialized object.
 */
- (id) initBusyIndicatorWithName:(NSString*)name;

@end
