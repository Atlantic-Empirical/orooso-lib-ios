//
//  ORContactItem.h
//  Orooso
//
//  Created by Thomas Purnell-Fisher on 10/1/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ORContact.h"

typedef enum _ORContactItemType
{
	ORContactItemTypeFb,
	ORContactItemTypePhone,
	ORContactItemTypeEmail,
	ORContactItemType_usersOwnFacebookNewsfeed,
	ORContactItemType_usersOwnTwitter,
	ORContactItemType_ConnectFacebook,
	ORContactItemType_ConnectGoogle
} ORContactItemType;

@interface ORContactItem : NSObject <NSCoding>

- (ORContactItem*) initWithDisplayName:(NSString*)displayName andType:(ORContactItemType) inType;

@property (strong, nonatomic) NSString *contactName;
@property (strong, nonatomic) NSString *contactInfo;
@property (assign, nonatomic) ORContactItemType type;
@property (strong, nonatomic) ORContact *originalContact;
@property (nonatomic, assign) BOOL selected;

+ (NSArray *)proxyForJsonWithArray:(NSArray *)items;
- (NSMutableDictionary *)proxyForJson;

@end
