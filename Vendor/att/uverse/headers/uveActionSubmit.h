//
//  uveActionSubmit.h
//  DAIS
//
//  Created by Erik Smith on 9/13/11.
//  Copyright 2011 AT&T. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uveAction.h"




/**
  
 Builds an HTTP query containing the values from gadgets on the page.
 
  If using as a single action outside of a uveActionContainer set the name property inherited from uveNode.
*/
@interface uveActionSubmit : uveAction { }

/** The name of the gadget from which to take the data for the submit. */
@property (nonatomic, retain) NSString* sourceGadgetName;
/** The array of gadget names from which to take the data for the submit.  */
@property (nonatomic, retain) NSArray* sourceGadgetNames;
/** The URL to which the submit should send its request. */
@property (nonatomic, retain) NSURL* URL;
/** YES if you want a "GET" request. NO if you want a "POST" request. */
@property (nonatomic, assign) BOOL methodGet;


/**
 Initializes a uveActionSubmit object. This init method allows the submit action to submit data from a single gadget. 
 @param name The name of this action. This can be nil if the action is being placed inside of a uveActionContainer or if the setName property is used, instead.
 @param sourceGadgetName The name of the gadget from which to take the data for the submit.
 @param URL The URL to which the submit should send its request.
 @param methodGet YES if you want a "GET" request. NO if you want a "POST" request.
 @returns The initialized uveActionNavigate object.
 */
- (id) initActionWithName:(NSString*)name
         sourceGadgetName:(NSString *)sourceGadgetName
                      URL:(NSURL *)URL
                methodGet:(BOOL)methodGet;

/**
 Initializes a uveActionSubmit object. This init method allows the submit action to submit data from multiple gadgets. 
 @param name The name of this action. This can be nil if the action is being placed inside of a uveActionContainer or if the setName property is used, instead.
 @param sourceGadgetNames The array of gadget names from which to take the data for the submit.
 @param URL The URL to which the submit should send it's request.
 @param methodGet YES if you want a "GET" request. NO if you want a "POST" request.
 @returns The initialized uveActionNavigate object.
 */
- (id) initActionWithName:(NSString*)name
    sourceGadgetNameArray:(NSArray *)sourceGadgetNames
                      URL:(NSURL *)URL
                methodGet:(BOOL)methodGet;


/**
 Initializes a uveActionSubmit object. This init method allows the submit action to submit data from a single gadget and the response will update the data for the target gadget. 
 @param name The name of this action. This can be nil if the action is being placed inside of a uveActionContainer or if the setName property is used, instead.
 @param sourceGadgetName The name of the gadget from which to take the data for the submit.
 @param targetControlName The name of the gadget whose data will be updated by the response.
 @param URL The URL to which the submit should send it's request.
 @param methodGet YES if you want a "GET" request. NO if you want a "POST" request.
 @returns The initialized uveActionNavigate object.
 */
- (id) initActionWithName:(NSString*)name
         sourceGadgetName:(NSString *)sourceGadgetName
        targetControlName:(NSString *)targetControlName
                      URL:(NSURL *)URL
                methodGet:(BOOL)methodGet;


/**
 Initializes a uveActionSubmit object. This init method allows the submit action to submit data from multiple gadgets and the response will update the data for the target gadget. 
 @param name The name of this action. This can be nil if the action is being placed inside of a uveActionContainer or if the setName property is used, instead.
 @param sourceGadgetNames The array of gadget names from which to take the data for the submit.
 @param targetControlName The name of the gadget whose data will be updated by the response.
 @param URL The URL to which the submit should send it's request.
 @param methodGet YES for a "GET" request. NO for a "POST" request.
 @returns The initialized uveActionNavigate object.
 */
- (id) initActionWithName:(NSString*)name
    sourceGadgetNameArray:(NSArray *)sourceGadgetNames
        targetControlName:(NSString *)targetControlName
                      URL:(NSURL *)URL
                methodGet:(BOOL)methodGet;



@end


