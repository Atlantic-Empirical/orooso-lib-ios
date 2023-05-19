//
//  uveLocalDataSource.h
//  DAIS
//
//  Created by Erik Smith on 7/5/12.
//  Copyright (c) 2012 AT&T. All rights reserved.
//

#import "uveDataSource.h"
/**  A datasource that can only be located on the local UVE device. Do not specifiy a protocol or address in the URL, only the name of the desired resource. */
@interface uveLocalDataSource : uveDataSource

@end
