//
//  ORContact.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 20/07/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ABPerson;

typedef enum _ORContactType
{
    ORContactTypeGoogle,
    ORContactTypeFacebook,
    ORContactTypePublish_FacebookNewsfeed,
    ORContactTypePublish_Twitter,
    ORContactTypeGoogle_connect,
    ORContactTypeFacebook_connect,
    ORContactTypeAddressBook,
    ORContactTypeTwitter
}
ORContactType;


@interface ORContact : NSObject <NSCoding>

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *im;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, assign) ORContactType type;
@property (nonatomic, readonly) NSString *typeName;
@property (nonatomic, strong) ABPerson *abPerson;

- (id)initWithGoogleData:(NSDictionary *)data;
- (id)initWithFacebookData:(NSDictionary *)data;
- (id)initWithTwitterId:(NSString *)twitterId;
- (id)initWithDisplayName:(NSString *)displayName andType:(ORContactType)inType;
- (id)initWithABPerson:(ABPerson *)person;

- (NSString *)contactHash;

@end
