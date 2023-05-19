//
//  uvePanel.h
//  DAIS
//
//  Created by Erik Smith on 4/3/12.
//  Copyright (c) 2012 AT&T. All rights reserved.
//

#import "uveGadget.h"
#import "uveFlowType.h"

/** A container for gadgets. Do not nest panels with delayLoadChildren set to YES. */
@interface uvePanel : uveGadget


/** The layout flow for the controls in the uvePanel. Values can be kNone, kHorizontal, kVertical. */
@property (nonatomic, assign) uveFlowType flow;
/** Clip child controls which fall outside the edge of the panel.  */
@property (nonatomic, assign) BOOL clipChildControls;
/**  If the panel is initially hidden, perceived performance may be improved. This works best with uvePanels that contain many controls.  */
@property (nonatomic, assign) BOOL delayLoadChildren;



/**
 Initializes the object.
 @returns The initialized object.
 */
- (id) init;

/**
 Initializes the object.
 @param name An identifier for the uvePanel object.
 @returns The initialized object.
 */
- (id) initPanelWithName:(NSString*)name;

/**
 Initializes the object.
 @param name An identifier for the uvePanel object.
 @param flow The layout flow for the controls in the uvePanel. Values may be kNone, kHorizontal or kVertical.
 @returns The initialized object.
 */
- (id) initPanelWithName:(NSString*)name flow:(uveFlowType)flow;

/**
 Adds a uveGadget object to the uvePanel object.
 @param gadget The gadget object to be added.
 */
- (void) addGadget:(uveGadget*)gadget;
/**
 Removes the uveGadget object with the given name.
 @param name An identifier for the uveGadget object to be removed from the gadget.
 */
- (void) removeGadget:(NSString *)name;


/**
 Adds an action to the panel.
 @param action The uveAction to be added.
 */
- (void) addAction:(uveAction*)action;




@end
