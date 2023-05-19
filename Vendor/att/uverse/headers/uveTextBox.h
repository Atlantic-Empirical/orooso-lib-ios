//
//  uveTextBox.h
//  DAIS
//
//  Created by Erik Smith on 7/28/11.
//  Copyright 2011 AT&T. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uveGadget.h"
#import "uveAction.h"
#import <UIKIT/UIColor.h>
#import <CoreGraphics/CGGeometry.h>
#import "uveFontType.h"
#import "uveActionContainer.h"
#import "uveTextBase.h"

/**
 Displays a multi-line text control on the uve Page.
 */
@interface uveTextBox : uveGadget { }
/** The uveAction object that is assigned to the onBlur event. */
@property (nonatomic, retain) uveAction* onBlur;
/** The uveAction object that is assigned to the onClick event. */
@property (nonatomic, retain) uveAction* onClick;
/** The uveAction object that is assigned to the onFocus event. */
@property (nonatomic, retain) uveAction* onFocus;
/** Associates a uveActionContainer with the pressing of a key on the remote. In the NSDictionary the key is the remote-key to be pressed and the object is the uveAction object. All keys on the remote can trigger this event. Associated actions must have the name property set. Different uveActions/uveActionContainers can not be assigned to the same remote control key. */
@property (nonatomic, retain) NSDictionary* onKey;

/** The number of pixels between the uveTextBox boundary and the scroll bar. */
@property (nonatomic, assign) int scrollbarOffset;
/** The maximum number of visible lines the uveTextBox object can display. */
@property (nonatomic, assign) int maximumLines;



/** Sets the glow color for the button when it receives the focus */
@property (nonatomic, retain) UIColor *focusGlowColor;
/** Sets the glow image for the button when it receives the focus */
@property (nonatomic, retain) NSURL *focusGlowImage;


/** The name of the gadget that will get the focus when the down button is pressed on the remote control. */
@property (nonatomic, retain) NSString* nextDown;
/** The name of the gadget that will get the focus when the left button is pressed on the remote control. */
@property (nonatomic, retain) NSString* nextLeft;
/** The name of the gadget that will get the focus when the right button is pressed on the remote control. */
@property (nonatomic, retain) NSString* nextRight;
/** The name of the gadget that will get the focus when the up button is pressed on the remote control. */
@property (nonatomic, retain) NSString* nextUp;




/** The font of the text. */
@property (nonatomic, assign) uveFontType font;
/** The color of the text. */
@property (nonatomic, retain) UIColor *fontColor;
/** This is the text displayed by the control */
@property (nonatomic, retain) NSString* text;


/** When wrap is true, leading specifies the space between lines. Non-negative. */
@property (nonatomic, assign) int leading;
/** Padding is the space between the inside edge of the control and the text the control contains. Padding is used to position the text it contains. This property does not effect child controls */
@property (nonatomic, assign) CGRect padding;
/** Set the justification for the text as kJustifyLeft, kJustifyCenter or kJustifyRight. */
@property (nonatomic, assign) uveJustificationType justification;






/**
 Initializes the uveTextBox object.
 @returns The initialized uveTextBox object.
 */
- (id)init;

/**
 Initializes the uveTextBox object.
 @param name An identifier for the uveTextBox object.
 @returns The initialized uveTextBox object.
 */
- (id)initTextBoxWithName:(NSString*)name;

/**
 Initializes the uveTextBox object.
 @param name An identifier for the uveTextBox object.
 @param text Text to be displayed in the uveTextBox.
 @returns The initialized uveTextBox object.
 */
- (id)initTextBoxWithName:(NSString*)name
                     text:(NSString*)text;

/**
 Initializes the uveTextBox object.
 @param name An identifier for the uveTextBox object.
 @param text Text to be displayed in the uveTextBox.
 @param frame The location and dimensions of the uveTextBox object on the uvePage.
 @returns The initialized uveTextBox object.
 */
- (id)initTextBoxWithName:(NSString*)name
                     text:(NSString*)text
                    frame:(CGRect)frame;


@end
