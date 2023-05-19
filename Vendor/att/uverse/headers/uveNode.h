//
//  uveNode.h
//  DAIS
//
//  Created by Erik Smith on 9/12/11.
//  Copyright 2011 AT&T. All rights reserved.


#import <Foundation/Foundation.h>

/**
 The base class for the uve class library and should be considered abstract. 
 */
@interface uveNode : NSObject <NSCopying> { }

/** An identifier for the uve object. Gadgets without a name can not be acted upon by actions or animations. If gadget names are not unique on the uvePage, actions and animations that target those controls will affect all controls with the same name. This is not recommended. If you desire to address multiple controls with a single action, place them within a panel and target the panel with the action or animation. */
@property (nonatomic, retain) NSString* name;


@end
