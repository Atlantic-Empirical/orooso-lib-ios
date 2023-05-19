//
//  uveActionNavigate.h
//  DAIS
//
//  Created by Erik Smith on 9/13/11.
//  Copyright 2011 AT&T. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uveAction.h"
/*! \file uveActionNavigate.h
 */

/*! \enum NavigationTargetType
 NavigationTargetType    Navigates to: 
 --------------------    --------------------------------------------------------------------------------
 kNoAction               Nothing.
 kBack                   Previous page in history, or back to live uvc if there is no history. 
 kDVR                    Recordings page. 
 kFavorites              Favorites page.  
 kGuide                  Program guide. 
 kMenu                   Menu page. 
 kSearch                 Search page. 
 kSearchTitle            Search with a title subset.  
 kSearchVOD              Search with a vod subset.  
 kSearchPeople           Search with a people subset.  
 kSearchProgramID        Search with a programid subset.   
 kSearchCallLetters      Search with a call letter subset.  
 kSettings               Settings page. 
 kTV                     Live TV. 
 kVOD                    Main VOD page. 
 */
typedef enum 
{
    kNoAction,
    kBack,
    kDVR,
    kFavorites,
    kGuide,
    kMenu,
    kSearch,
    kSearchTitle,
    kSearchVOD,
    kSearchPeople,
    kSearchProgramID,
    kSearchCallLetters,
    kSettings,
    kTV,
    kVOD
} NavigationTargetType;

/**

 The destination of the navigation action can be a uvePage, a channel, or a STB function like the program guide ( represented by the NavigationTargetType ). Some of the properties are mutually exclusive. If navigationTarget, channel, url are set then they unset the others.
  If using as a single action outside of a uveActionContainer set the name property inherited from uveNode.

 */
@interface uveActionNavigate : uveAction { }

/** The desitination of the navigation request. See table of NavigationTargetType. */
@property (nonatomic, assign) NavigationTargetType navigationTarget;
/** The destination channel. */
@property (nonatomic, assign) unsigned int channel;
/** The destination page. */
@property (nonatomic, retain) NSURL* url;
/** The the time and date of the program on the channel specified in the channel parameter. */
@property (nonatomic, retain) NSDate* localTimeWithDate;

// actionNavigate does not have a targetControl


/**
 NavigationTargetType    Navigates to: 
 --------------------    --------------------------------------------------------------------------------
 kNoAction               No action occurs.
 kBack                   Previous page in history, or back to live uvc if there is no history. 
 kDVR                    Recordings page. 
 kFavorites              Favorites page.  
 kGuide                  Program guide. 
 kMenu                   Menu page. 
 kSearch                 Search page. 
 kSearchTitle            Search with a title subset.  
 kSearchVOD              Search with a vod subset.  
 kSearchPeople           Search with a people subset.  
 kSearchProgramID        Search with a programid subset.   
 kSearchCallLetters      Search with a call letter subset.  
 kSettings               Settings page. 
 kTV                     Live TV. 
 kVOD                    Main VOD page. 

@param name The name of this action. This can be nil if the action is being placed inside of a uveActionContainer or if the setName property is used, instead.
@param navigationTarget The desitination of the navigation request. See table of NavigationTargetType.
@returns The initialized uveActionNavigate object.
*/
- (id) initActionWithName:(NSString*)name
         navigationTarget:(NavigationTargetType)navigationTarget;


/**
 Set to zero if not in use.
 @param name The name of this action. This can be nil if the action is being placed inside of a uveActionContainer or if the setName property is used, instead.
 @param channel The destination channel.
 @returns The initialized uveActionNavigate object.
 */
- (id) initActionWithName:(NSString*)name
        navigateToChannel:(unsigned int)channel;

/**
 This will throw an exception if nil is given for the url.
 @param name The name of this action. This can be nil if the action is being placed inside of a uveActionContainer or if the setName property is used, instead.
 @param url The destination page.
 @returns The initialized uveActionNavigate object.
 */
- (id) initActionWithName:(NSString*)name
            navigateToURL:(NSURL*)url;

/**
 @param name The name of this action. This can be nil if the action is being placed inside of a uveActionContainer or if the setName property is used, instead.
 @param channel The destination channel. Set channel to zero if not in use.
 @param localTimeWithDate The the time and date of the program on the channel specified in the channel parameter.
 @returns The initialized uveActionNavigate object.
 */
- (id) initActionWithName:(NSString*)name
        navigateToChannel:(unsigned int)channel
        localTimeWithDate:(NSDate *)localTimeWithDate;

@end



