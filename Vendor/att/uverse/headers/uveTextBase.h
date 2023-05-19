//
//  uveTextBase.h
//  DAIS
//
//  Created by Erik Smith on 4/9/12.
//  Copyright (c) 2012 AT&T. All rights reserved.
//

#import "uveGadget.h"
#import "uveJustificationType.h"
#import "uveFontType.h"

/** An abstract class, do not instantiate. */
@interface uveTextBase : uveGadget


/** The font of the text. */
@property (nonatomic, assign) uveFontType font;
/** The color of the text. */
@property (nonatomic, retain) UIColor *fontColor;
/** This is the text displayed by the control */
@property (nonatomic, retain) NSString* text;


/** This will clip text that is beyond the length of the control. */
@property (nonatomic, assign) BOOL clipText;
/** This will cause the text to use the ellipsis when it runs out of space. */
@property (nonatomic, assign) BOOL ellipsis;
/** When wrap is true, specifies the space between lines. Non-negative. */
@property (nonatomic, assign) int leading;
/** Padding is the space between the inside edge of the control and the text the control contains. Padding is used to position the text it contains. This property does not effect child controls */
@property (nonatomic, assign) CGRect padding;
/** If NO (default), text is displayed in a single line text box. If YES, text is displayed in a multiline text box. */
@property (nonatomic, assign) BOOL wrap;
/** Set the justification for the text as kJustifyLeft, kJustifyCenter or kJustifyRight. */
@property (nonatomic, assign) uveJustificationType justification;



@end
