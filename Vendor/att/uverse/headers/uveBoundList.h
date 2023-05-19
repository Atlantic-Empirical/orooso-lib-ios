//
//  uveBoundList.h
//  DAIS
//
//  Created by Erik Smith on 4/4/12.
//  Copyright (c) 2012 AT&T. All rights reserved.
//

#import "uveGadget.h"
#import "uveFlowType.h"
#import "uveListItemTemplate.h"

/** A list bound to a data source. Contains uveListItemTemplates. */
@interface uveBoundList : uveGadget

/**
 Initializes the object.
 @returns The initialized object.
 */
- (id) init;

/**
 Initializes the object.
 @param name An identifier for the uveBoundList object.
 @returns The initialized object.
 */
- (id) initBoundListWithName:(NSString*)name;

/**
 Initializes the object.
 @param name An identifier for the uveBoundList object.
 @param frame The dimensions of the uveBoundList. 
 @returns The initialized object.
 */
- (id) initBoundListWithName:(NSString*)name frame:(CGRect)frame;

/** If true, the list counter will always be shown. If NO, the list counter will only be shown when the uveBoundList has the focus. */
@property (nonatomic, assign) BOOL                  alwaysShowCounter;
/** The horizontal padding between the list item and the arrow. This is used only when the flow property is set to kHorizontal. Must be zero or greater. */
@property (nonatomic, assign) short          arrowHorizontalOffset;
/** The vertical padding between the list item and the arrow. This is used only when the flow property is set to kVertical. Must be zero or greater. */
@property (nonatomic, assign) short          arrowVerticalOffset;
/** Determines the layout flow of the controls in the uveBountList. This can be kNone, kHorizontal or kVertical. */
@property (nonatomic, assign) uveFlowType           flow;
/** The name of the animation that will occur when an item in the uveBoundList recieves the focus. */
@property (nonatomic, retain) NSString              *focusAnimation;
/** The index of the item for the first request. */
@property (nonatomic, assign) unsigned int          initialStartIndex;
/** The name of the control to hold the value of the list counter. */
@property (nonatomic, retain) NSString              *listCounterName;
/** The action(s) that will occur when the control load results in an error. */
@property (nonatomic, retain) uveAction             *onError;

/** Associates a uveAction with the pressing of a key on the remote. In the NSDictionary the key is the remote-key to be pressed and the object is the uveAction object. All keys on the remote can trigger this event. Associated actions must have the name property set. Different uveActions/uveActionContainers can not be assigned to the same remote control key. */
@property (nonatomic, retain) NSDictionary* onKey;


/** The action(s) that will occur when the control is ready. */
@property (nonatomic, retain) uveAction             *onReady;
/** Number of items to request on each fetch. */
@property (nonatomic, assign) unsigned int          prefetchAmount;
/**  The total number of visible items in the list. The range is 0 to 250, inclusive. The range is 0 to 250, inclusive, if the user exceeds 250, an exception will be thrown. */
@property (nonatomic, assign) unsigned int          visibleItemCount;

/** The uveListItemTemplates for the uveBoundList. */
@property (nonatomic, retain) NSArray *listItemTemplates;
@end

