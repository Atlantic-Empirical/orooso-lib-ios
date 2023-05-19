//
//  ORHourMinuteSecond.m
//  Orooso
//
//  Created by Thomas Purnell-Fisher on 10/10/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "ORHourMinuteSecond.h"

@implementation ORHourMinuteSecond

- (ORHourMinuteSecond*)initWithMilliseconds:(int)milliseconds {
	return [self initWithSeconds:milliseconds/1000];
}

- (ORHourMinuteSecond*)initWithSeconds:(int)seconds {
	self = [super init];
	if (self) {
		// do the hours first: there are 3600 seconds in an hour, so if we divide
		// the total number of seconds by 3600 and throw away the remainder, we're
		// left with the number of hours in those seconds
		self.hours = seconds / 3600;
		
		// dividing the total seconds by 60 will give us the number of minutes
		// in total, but we're interested in *minutes past the hour* and to get
		// this, we have to divide by 60 again and then use the remainder
		self.minutes = (seconds/ 60) % 60;
		
		// seconds past the minute are found by dividing the total number of seconds
		// by 60 and using the remainder
		self.seconds = seconds % 60;
		
		self.totalHours = (float)3600.0f / (float)seconds;
		self.totalMinutes = (float)60.0f / (float)seconds;
		self.totalSeconds = seconds;
		self.totalMillis = seconds * 1000;
		
	}
	return self;
}

- (NSString*)friendlyString_HMMSS {
	return [NSString stringWithFormat:@"%@:%@:%@", [NSString stringWithFormat:@"%d", self.hours], [self padStringToTwoCharacters:self.minutes], [self padStringToTwoCharacters:self.seconds]];
}

- (NSString*)friendlyString_HMS {
	if (self.totalMillis == 0) return @"Unavailable";
	
	NSString *result = @"";
	
	if (self.hours > 0)
		result = [NSString stringWithFormat:@"%dh", self.hours];
	if (self.minutes > 0 || self.hours > 0)
		result = [NSString stringWithFormat:@"%@ %dm", result, self.minutes];
	if (self.hours > 0 || self.minutes > 0 || self.seconds > 0)
		result = [NSString stringWithFormat:@"%@ %ds", result, self.seconds];
	result = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	return result;
}

- (NSString*) padStringToTwoCharacters:(int)num {
	NSString *padded = [NSString stringWithFormat:@"%02d", num];
	return padded;
}

@end
