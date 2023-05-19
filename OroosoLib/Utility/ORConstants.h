//
//  ORConstants.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 21/05/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#define ISIPAD  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define P_CARD_SIZE         (ISIPAD ? CGSizeMake(369.0f, 277.0f) : CGSizeMake(300.0f, 225.0f))
#define P_CARD_SIZE_DOUBLE  (ISIPAD ? CGSizeMake(748.0f, 564.0f) : CGSizeMake(300.0f, 225.0f))
#define P_CARD_SIZE_SMALL   (ISIPAD ? CGSizeMake(100.0f, 100.0f) : CGSizeMake(100.0f, 100.0f))

#define L_CARD_SIZE         (ISIPAD ? CGSizeMake(400.0f, 300.0f) : CGSizeMake(300.0f, 189.0f))
#define L_CARD_SIZE_DOUBLE  (ISIPAD ? CGSizeMake(810.0f, 610.0f) : CGSizeMake(300.0f, 189.0f))
#define L_CARD_SIZE_SMALL   (ISIPAD ? CGSizeMake(100.0f, 100.0f) : CGSizeMake(100.0f, 100.0f))

#define TSD_CARD_HEIGHT     224.0f
#define TSD_CARD_WIDTH      298.0f

#define AVATAR_SIZE         (ISIPAD ? CGSizeMake(49.0f, 49.0f) : CGSizeMake(49.0f, 49.0f))
