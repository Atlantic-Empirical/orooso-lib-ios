//
//  uvePage.h
//  DAIS
//
//  Created by Arnold Goldberg on 7/21/11.
//  Modified by Erik Smith
//  Copyright 2011 AT&T. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "uveGadget.h"
#import "uveAction.h"
#import "uveAnimationContainer.h"
#import "uveActionContainer.h"
#import "uveMediaProfile.h"


/*! \file uvePage.h
 */

/*! \enum uvePageDimensionsType
These are the possible page dimensions:
 kAutomatic, kWidescreen, kAbsolute, kNTSC, kPAL
 */
typedef enum
{
    kAutomatic, kWidescreen, kAbsolute, kNTSC, kPAL 
        
} uvePageDimensionsType;


/**
 A container for uveGadgets.
 */
@interface uvePage : uveGadget { }

/** Causes an action to execute when the page is displayed. */
@property (nonatomic, retain) uveAction* onEnter;
/** Causes an action to execute when the user leaves the page. */
@property (nonatomic, retain) uveAction* onLeave;
/** Performs an action just before the Client enters the standby power state. */
@property (nonatomic, retain) uveAction* onSleep;
/** Perform an action when the navigation returns back to the visited page, such as from history. */
@property (nonatomic, retain) uveAction* onReturn;
/** Associates a uveActionContainer with the pressing of a key on the remote. In the NSDictionary the key is the remote-key to be pressed and the object is the uveAction object. All keys on the remote can trigger this event. Associated actions must have the name property set. Different uveActions/uveActionContainers can not be assigned to the same remote control key. */
@property (nonatomic, retain) NSDictionary* onKey;
/** Sets the screen rendering dimensions. */
@property (nonatomic, assign) uvePageDimensionsType pageDimensions;
/** The background may be set to black ( YES ) or transparent ( NO ). The default is YES. If a non-pip video is included on the page set blackBackground to NO. */
@property (nonatomic, assign) BOOL blackBackground;
/** Detunes the fullscreen video and audio. Defaults to YES. */
@property (nonatomic, assign) BOOL detuneVideo;


/**
 Initializes the page.
 @returns An initialized uvePage object.
 */
- (id) init;

/**
 Initializes the page with an identifier.
 @param name An identifier for the uvePage object.
 @returns An initialized uvePage object.
 */
- (id) initPageWithName:(NSString*)name;


/**
 Adds an action to the page.
 @param action The uveAction to be added.
 */
- (void) addAction:(uveAction*)action;


/**
Adds a uveAnimationContainer container to the page.
 @param animationContainer The uveAnimationContainer object to be added to the page.
 */
- (void) addAnimationContainer:(uveAnimationContainer *)animationContainer;
/**
Removes the uveAnimation container with the given name.
 @param name An identifier for the object to be removed from the page.
 */
- (void) removeAnimationContainer:(NSString *)name;


/**
 Adds a uveGadget object to the uvePage object. 
 @param gadget The gadget object to be added.
 */
- (void) addGadget:(uveGadget*)gadget;
/**
 Removes the uveGadget object with the given name.
 @param name An identifier for the uveGadget object to be removed from the gadget.
 */
- (void) removeGadget:(NSString *)name;


/**
 Add a custom event to the uvePage object. The custom event may be activated by using a uveCustomAction.  @param eventName The name of the custom event should not contain punctuation.
 @param action This should contain the uveActions that will be invoked when the custom event occurs.
 
 */
- (void) addCustomEventWithName:(NSString*)eventName action:(uveAction*)action;

/**
 Removes the custom event object with the given name.
 @param eventName An identifier for the object to be removed.
 */
- (void) removeCustomEventWithName:(NSString*)eventName;

/**
 Adds the uveMediaProfile object with the given name to the page.
 @param mediaProfile An mediaProfile object to be added.
 */
- (void) addMediaProfile:(uveMediaProfile*)mediaProfile;

/**
 Removes the uveMediaProfile object with the given name.
 @param name An identifier for the object to be removed.
 */
- (void) removeMediaProfileByName:(NSString*)name;

@end
