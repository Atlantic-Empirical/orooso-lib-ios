//
//  uveVideoListItem.h
//  DAIS
//
//  Created by Erik Smith on 4/5/12.
//  Copyright (c) 2012 AT&T. All rights reserved.
//

#import "uveGadget.h"
#import "uveJustificationType.h"
#import "uveVerticalAlignmentType.h"
#import "uveTextBase.h"


/** One of the controls that can be placed inside a list. */
@interface uveVideoListItem : uveTextBase

/** The color that will be used on the uveVideoListItem background when the focus is obtained. */
@property (nonatomic, retain) UIColor *focusBackgroundColor;
/** The image that will be used on the uveVideoListItem background when the focus is obtained. */
@property (nonatomic, retain) NSURL *focusBackgroundImage;

/** The color that will be used on the uveVideoListItem foreground when the focus is obtained. */
@property (nonatomic, retain) UIColor *focusForegroundColor;

/** Sets the glow color for the uveVideoListItem when it receives the focus */
@property (nonatomic, retain) UIColor *focusGlowColor;
/** Sets the glow image for the uveVideoListItem when it receives the focus */
@property (nonatomic, retain) NSURL *focusGlowImage;

/** Sets the image of the uveVideoListItem for when it is pressed. */
@property (nonatomic, retain) NSURL *pressedImage;
/** Sets the color of the uveVideoListItem for when it is pressed. */
@property (nonatomic, retain) UIColor *pressedColor;

/** The URL to navigate to when the uveVideoListItem is pressed. */
@property (nonatomic, retain) NSURL *href;

/** The name of the gadget that will get the focus when the down button is pressed on the remote control. */
@property (nonatomic, retain) NSString* nextDown;
/** The name of the gadget that will get the focus when the left button is pressed on the remote control. */
@property (nonatomic, retain) NSString* nextLeft;
/** The name of the gadget that will get the focus when the right button is pressed on the remote control. */
@property (nonatomic, retain) NSString* nextRight;
/** The name of the gadget that will get the focus when the up button is pressed on the remote control. */
@property (nonatomic, retain) NSString* nextUp;


/** The uveAction object that is assigned to the onBlur event. */
@property (nonatomic, retain) uveAction* onBlur;
/** The uveAction object that is assigned to the onClick event. */
@property (nonatomic, retain) uveAction* onClick;
/** The uveAction object that is assigned to the onFocus event. */
@property (nonatomic, retain) uveAction* onFocus;
/** Associates a uveActionContainer with the pressing of a key on the remote. In the NSDictionary the key is the remote-key to be pressed and the object is the uveAction object. All keys on the remote can trigger this event. Associated actions must have the name property set. Different uveActions/uveActionContainers can not be assigned to the same remote control key. */
@property (nonatomic, retain) NSDictionary* onKey;

/** The vertical alignment of text. kVerticalBottom, kVerticalCenter or kVerticalTop. */
@property (nonatomic, assign) uveVerticalAlignmentType verticalAlignment;



/** The frame for the video, not the uveVideoListItem control. */
@property (nonatomic, assign) CGRect videoFrame;


/** The channel to which the uveVideoListItem object will be tuned. */
@property (nonatomic, assign) unsigned int channel;
/** The call letters to which the object will be tuned, such as CNN. */
@property (nonatomic, retain) NSString *callLetters;
/** The URL to which the uveVideoListItem object will be tuned. Only live PiPs can be tuned. */
@property (nonatomic, retain) NSURL *tuneURL;
/** YES will cause the this uveVideoListItem object to detune */
@property (nonatomic, assign) BOOL detune;


/**
 Initializes the uveVideoListItem object.
 @returns The initialized object.
 */
- (id)init;

/**
 Initializes the uveVideoListItem object.
 @param name An identifier for the object.
 @returns The initialized object.
 */
- (id)initVideoListItemWithName:(NSString*)name;


/**
 Initializes the uveVideoListItem object.
 @param name An identifier for the object.
 @param channel The numeric channel to which the video control will be tuned.
 @param frame The coordinates of the upper left corner of the control and its dimensions.
 @returns The initialized object.
 */
- (id)initVideoListItemWithName:(NSString*)name channel:(unsigned int)channel frame:(CGRect)frame;


/**
 Initializes the uveVideoListItem object.
 @param name An identifier for the object.
 @param callLetters The call letters of the channel to which the video conrol will be tuned.
 @param frame The coordinates of the upper left corner of the control and its dimensions.
 @returns The initialized object.
 */
- (id)initVideoListItemWithName:(NSString*)name callLetters:(NSString*)callLetters frame:(CGRect)frame;

/**
 Initializes the uveVideoListItem object. 
 @param name An identifier for the object.
 @param tuneURL The URL of the resource to which the video control will be tuned.
 @param frame The coordinates of the upper left corner of the control and its dimensions.
 @returns The initialized object.
 */
- (id)initVideoListItemWithName:(NSString*)name tuneURL:(NSURL*)tuneURL frame:(CGRect)frame;



@end

