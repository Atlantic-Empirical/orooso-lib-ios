//
//  ORSFWebsite.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 17/04/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFItem.h"

@interface ORSFWebsite : ORSFItem

@property (strong, nonatomic) NSString *imageName;
@property (strong, nonatomic) NSString *avatarName;

- (id)initWithURLString:(NSString *)url andEntity:(OREntity *)entity;
- (id)initWithORURL:(ORURL *)url andEntity:(OREntity *)entity;

@end
