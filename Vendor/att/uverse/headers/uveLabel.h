//
//  uveLabel.h
//  DAIS
//
//  Created by Erik Smith on 7/27/11.
//  Copyright 2011 AT&T. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "uveTextBase.h"
#import <UIKIT/UIColor.h>
#import "uveFontType.h"
#import "uveJustificationType.h"


/** Displays text on a uvePage. */
@interface uveLabel : uveTextBase { }


/**
 Initializes the uveLabel object.
 @returns The initialized uveLabel object.
 */
- (id)init;

/**
 Initializes the uveLabel object.
 @param name An identifier for the object.
 @returns The initialized uveLabel object.
 */
- (id)initLabelWithName:(NSString*)name;


/**
 Initializes the uveLabel object.
 @param name An identifier for the object.
 @param text The text that will be displayed by the label.
 @returns The initialized uveLabel object.
 */
- (id)initLabelWithName:(NSString*)name
                   text:(NSString*)text;


/**
 Initializes the uveLabel object.
 @param name An identifier for the object.
 @param text The text that will be displayed by the label.
 @param frame The location and dimensions of the label.
 @returns The initialized uveLabel object.
 */
- (id)initLabelWithName:(NSString*)name
                   text:(NSString*)text
                  frame:(CGRect)frame;

@end
