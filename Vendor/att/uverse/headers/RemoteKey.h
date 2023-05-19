//
//  RemoteKey.h
//
//  Created by Arnold Goldberg on 3/16/11.
//  Copyright 2011 AT&T Labs, Inc. All rights reserved.
//
/*! \file RemoteKey.h
 */

/*! \enum RemoteKey
 An enumeration of remote control keys that can be sent to the SetTopBox
 */
typedef enum RemoteKey
{
	RK_asterisk = 0,     /**< The * button */ 
	RK_pound    = 1,     /**< The # button */ 
	RK_zero     = 2,     /**< The 0 button */ 
	RK_one      = 3,     /**< The 1 button */ 
	RK_two      = 4,     /**< The 2 button */ 
	RK_three    = 5,     /**< The 3 button */ 
	RK_four     = 6,     /**< The 4 button */ 
	RK_five     = 7,     /**< The 5 button */ 
	RK_six      = 8,     /**< The 6 button */ 
	RK_seven    = 9,     /**< The 7 button */ 
	RK_eight    = 10,    /**< The 8 button */ 
	RK_nine     = 11,    /**< The 9 button */ 
	RK_app1     = 12,    /**< The App 1 button */ 
	RK_app2     = 13,    /**< The App 2 button */ 
	RK_app3     = 14,    /**< The App 3 button */ 
	RK_app4     = 15,    /**< The App 4 button */ 
	RK_app5     = 16,    /**< The App 5 button */ 
	RK_app6     = 17,    /**< The App 6 button */ 
	RK_blue     = 18,    /**< The blue button */ 
	RK_green    = 19,    /**< The green button */ 
	RK_red      = 20,    /**< The red button */ 
	RK_yellow   = 21,    /**< The yellow button */ 
	RK_channelup   = 22, /**< The Channel Down button */ 
	RK_channeldown = 23, /**< The Channel Up button */ 
	RK_up       = 24,    /**< The Up Navigation button */ 
	RK_down     = 25,    /**< The Down Navigation button */ 
	RK_left     = 26,    /**< The Left Navigation button */
	RK_right    = 27,    /**< The Right Navigation button */
	RK_select   = 28,    /**< The Select button */
	RK_back     = 29,    /**< The Back button */
	RK_enter    = 30,    /**< The Enter button */
	RK_clear    = 31,    /**< The Clear button */
	RK_exit     = 32,    /**< The Exit button */
	RK_favorites = 33,   /**< The Favorites button */
	RK_info     = 34,    /**< The Info button */
	RK_menu     = 35,    /**< The Menu button */
	RK_options  = 36,    /**< The Options button */
	RK_recordedtv = 37,  /**< The Recorded TV button */
	RK_guide    = 38,    /**< The Guide button */
	RK_help     = 39,    /**< The Help button */
	RK_recent   = 40,    /**< The Recent button */
	RK_search   = 41,    /**< The Search button */
	RK_teletext = 42,    /**< The Teletext button */
	RK_vod      = 43,    /**< The Video on Demand button */
	RK_ffwd     = 44,    /**< The Fast Forward button */
	RK_rwd      = 45,    /**< The Rewind button */
	RK_pause    = 46,    /**< The Pause button */
	RK_play     = 47,    /**< The Play button */
	RK_playpause = 48,   /**< The Play/Pause button */
	RK_power    = 49,    /**< The Power On/Power Off button */
	RK_poweron  = 50,    /**< The Power On button */
	RK_stop     = 51,    /**< The Stop button */
	RK_record   = 52,    /**< The Record button */
	RK_skipback = 53,    /**< The Skip Back button */
	RK_skipfwd  = 54,    /**< The Skip Forward button */
    RK_poweroff = 55,    /**< The Power Off button */
    RK_backspace = 56    /**< Backspace */
} RemoteKey;
