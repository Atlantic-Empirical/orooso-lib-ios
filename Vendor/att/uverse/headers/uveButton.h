//
//  uveButton.h
//  DAIS
//
//  Created by Arnold Goldberg on 7/21/11.
//  Modified by Erik Smith
//  Copyright 2011 AT&T. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "uveGadget.h"
#import "uveAction.h"
#import <UIKIT/UIColor.h>
#import "uveFontType.h"
#import "uveActionContainer.h"
#import "uveTextBase.h"

/** Displays a button on the uvePage. */
@interface uveButton : uveTextBase { }

/** The uveAction object that is assigned to the onBlur event. */
@property (nonatomic, retain) uveAction* onBlur;
/** The uveAction object that is assigned to the onClick event. */
@property (nonatomic, retain) uveAction* onClick;
/** The uveAction object that is assigned to the onFocus event. */
@property (nonatomic, retain) uveAction* onFocus;
/** Associates a uveActionContainer with the pressing of a key on the remote. In the NSDictionary the key is the remote-key to be pressed and the object is the uveAction object. All keys on the remote can trigger this event. Associated actions must have the name property set. Different uveActions/uveActionContainers can not be assigned to the same remote control key. */
@property (nonatomic, retain) NSDictionary* onKey;


/** The name of the gadget that will get the focus when the down button is pressed on the remote control. */
@property (nonatomic, retain) NSString* nextDown;
/** The name of the gadget that will get the focus when the left button is pressed on the remote control. */
@property (nonatomic, retain) NSString* nextLeft;
/** The name of the gadget that will get the focus when the right button is pressed on the remote control. */
@property (nonatomic, retain) NSString* nextRight;
/** The name of the gadget that will get the focus when the up button is pressed on the remote control. */
@property (nonatomic, retain) NSString* nextUp;

/** Sets the glow color for the button when it receives the focus */
@property (nonatomic, retain) UIColor *focusGlowColor;
/** Sets the glow image for the button when it receives the focus */
@property (nonatomic, retain) NSURL *focusGlowImage;

/** Sets the image of the button for when it is pressed. */
@property (nonatomic, retain) NSURL *pressedImage;
/** Sets the color of the button for when it is pressed. */
@property (nonatomic, retain) UIColor *pressedColor;

/** The image that will be used on the button background when the focus is obtained. */
@property (nonatomic, retain) NSURL *focusBackgroundImage;
/** The color that will be used on the button background when the focus is obtained. */
@property (nonatomic, retain) UIColor *focusBackgroundColor;

/** The color that will be used on the button foreground when the focus is obtained. */
@property (nonatomic, retain) UIColor *focusForegroundColor;

/** The URL to navigate to when the button is pressed. */
@property (nonatomic, retain) NSURL *href;


/**
 Initializes the uveButton object.
 @returns An initialized uveButton object.
 */
- (id)init;

/**
 Initializes the uveButton object.
 @param name An identifier for the object.
 @returns An initialized uveButton object.
 */
- (id)initButtonWithName:(NSString*)name;

/**
 Initializes the uveButton object.
 @param name An identifier for the object.
 @param text The text to be displayed on the object.
 @returns An initialized uveButton object.
 */
- (id)initButtonWithName:(NSString*)name
                    text:(NSString*)text;

/**
 Initializes the uveButton object.
 @param name An identifier for the object.
 @param text The text to be displayed on the object.
 @param frame The location and dimensions of the uveButton on the uvePage.
 @returns An initialized uveButton object.
 */
- (id)initButtonWithName:(NSString*)name
                    text:(NSString*)text
                   frame:(CGRect)frame;

@end
