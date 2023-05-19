//
//  ORSFPairPrompt.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 21/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "ORSFItem.h"

@interface ORSFPairPrompt : ORSFItem

@property (strong, nonatomic) NSString *imageName;

- (id)initWithId:(NSString *)itemId title:(NSString *)title content:(NSString *)content;

@end
