//
//  uveList.h
//  DAIS
//
//  Created by Erik Smith on 11/9/11.
//  Copyright 2011 AT&T. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uveNode.h"
#import "uveGadget.h"
#import "uveFlowType.h"

/**
This class displays a list of controls on the uvePage. Controls that may be used: uveButton.
*/
@interface uveList : uveGadget { }


/** The visible number of items in the list. The range is 0 to 250, inclusive, if the user exceeds 250, an exception will be thrown. */
@property (nonatomic, assign) unsigned int visibleItemCount;

/** The horizontal space between the list and the arrow. This is used only when the flow property is set to kHorizontal. Must be zero or greater. */
@property (nonatomic, assign) int arrowHorizontalOffset;

/** The vertical space between the list and the arrow. This is used only when the flow property is set to kVertical. Must be zero or greater. */
@property (nonatomic, assign) int arrowVerticalOffset;

/** The flow behavior of the child controls. */
@property (nonatomic, assign) uveFlowType flow;

/** The name of a uveLabel that will display the counter for the list. */
@property (nonatomic, retain) NSString *listCounterName;

/** The name of the animation that will occur when an item in the uveList recieves the focus. */
@property (nonatomic, retain) NSString              *focusAnimation;

/** If YES, the list counter will always be shown. If NO, the list counter will only be shown when the uveList has the focus. */
@property (nonatomic, assign) BOOL                  alwaysShowCounter;

/**
 Initializes the uveList object.
 @returns The initialized object.
 */
- (id)init;


/**
 Initializes the uveList object.
 @param name An identifier for the object.
 @returns The initialized object.
 */
- (id)initListWithName:(NSString*)name;


/**
 Initializes the uveList object.
 @param name An identifier for the object.
 @param frame The size and location.
 @returns The initialized object.
 */
- (id)initListWithName:(NSString*)name frame:(CGRect)frame;

/**
 Adds a uveGadget object to the uveList object. If a second gadget is added with the same name as a previously added gadget, the second gadget will replace the first gadget.
 @param gadget The gadget object to be added.
 */
- (void) addGadget:(uveGadget*)gadget;
/**
 Removes the uveGadget object with the given name.
 @param name An identifier for the uveGadget object to be removed from the gadget.
 */
- (void) removeGadget:(NSString *)name;


@end
