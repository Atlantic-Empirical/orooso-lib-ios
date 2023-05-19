//
//  main.m
//  OroosoLibTest
//
//  Created by Rodrigo Sieiro on 23/11/2012.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
		int retVal;
		@try {
			retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
		}
		@catch (NSException *exception) {
			NSLog(@"Uncaught exception %@", exception);
			NSLog(@"Stack trace: %@", [exception callStackSymbols]);
		}
        return retVal;
    }
}
