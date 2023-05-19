//
//  uveListItemTemplate.h
//  DAIS
//
//  Created by Erik Smith on 4/6/12.
//  Copyright (c) 2012 AT&T. All rights reserved.
//

#import "uveGadget.h"

/** This is used within a uveBoundList. uveListItemTemplate may contain uveLabel, uveButton, uveImage objects. */
@interface uveListItemTemplate : uveGadget

/** The case-sensitive name of the node in the xml data source to map to. */
@property (nonatomic, retain) NSString *templateName;
/** The path in the data source to the value of an item. Used for submits. */
@property (nonatomic, retain) NSString *valuePath;
/** The URL to navigate to. */
@property (nonatomic, retain) NSURL *href;


/** The uveAction object that is assigned to the onBlur event. */
@property (nonatomic, retain) uveAction* onBlur;
/** The uveAction object that is assigned to the onClick event. */
@property (nonatomic, retain) uveAction* onClick;
/** The uveAction object that is assigned to the onFocus event. */
@property (nonatomic, retain) uveAction* onFocus;
/** Associates a uveActionContainer with the pressing of a key on the remote. In the NSDictionary the key is the remote-key to be pressed and the object is the uveAction object. All keys on the remote can trigger this event. Associated actions must have the name property set. Different uveActions/uveActionContainers can not be assigned to the same remote control key. */
@property (nonatomic, retain) NSDictionary* onKey;




/**
 Initializes the uveListItemTemplate.
 @returns An initialized uveListItemTemplate object.
 */
- (id) init;

/**
 Initializes the uveListItemTemplate with an identifier.
 @param name An identifier for the uveListItemTemplate object.
 @returns An initialized uveListItemTemplate object.
 */
- (id) initListItemTemplateWithName:(NSString*)name;


/**
 Adds an action to the uveListItemTemplate. 
 @param action The uveAction to be added.
 */
- (void) addAction:(uveAction*)action;


/**
 Adds a uveAnimationContainer container to the uveListItemTemplate.
 @param animationContainer The uveAnimationContainer object to be added to the uveListItemTemplate.
 */
- (void) addAnimationContainer:(uveAnimationContainer *)animationContainer;
/**
 Removes the uveAnimation container with the given name.
 @param name An identifier for the object to be removed from the uveListItemTemplate.
 */
- (void) removeAnimationContainer:(NSString *)name;


/**
 Adds labels, buttons and images to the uveListItemTemplate object. Any other type will be ignored.
 @param gadget The gadget object to be added.
 */
- (void) addGadget:(uveGadget*)gadget;
/**
 Removes the uveGadget object with the given name.
 @param name An identifier for the uveGadget object to be removed.
 */
- (void) removeGadget:(NSString *)name;


@end
