//
//  uveAction.h
//  DAIS
//
//  Created by Erik Smith on 9/13/11.
//  Copyright 2011 AT&T. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uveNode.h"

/** An abstract class. */
@interface uveAction : uveNode { }

/** The name of the target control to be affected by the action. This is mutually exclusive with targetControlNames. */
@property (nonatomic, retain) NSString* targetControlName;

/** The names of the controls to be affected. NSArray of NSString. This is mutually exclusive with targetControlName. */
@property (nonatomic, retain) NSSet* targetControlNames;

@end
