//
//  ORUverseTitle.m
//  Orooso
//
//  Created by Thomas Purnell-Fisher on 11/25/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "ORUverseTitle.h"

@implementation ORUverseTitle

- (ORUverseTitle*)initWithUverseProgram:(uverseProgram*)uvProg {
	self = [super init];
	if (self){
		self.programTitle = uvProg.title;
		self.channel = [NSString stringWithFormat:@"%d", uvProg.channel];
		self.time = [uvProg.time description];
		self.programDescription = uvProg.description;
		self.episodeName = uvProg.episode;
		self.duration = uvProg.duration;
		self.programType = [NSString stringWithFormat:@"%d", uvProg.type];
		self.tuneString = uvProg.tuneString;
		self.dvrStatus = [NSString stringWithFormat:@"%d", uvProg.dvrStatus];
		self.ratings = uvProg.ratings;
	}
	return self;
}

@end
