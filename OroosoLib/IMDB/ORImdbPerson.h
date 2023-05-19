//
//  ORIMDBPerson.h
//  OroosoLib
//
//  Created by Rodrigo Sieiro on 28/09/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

@interface ORImdbPerson : NSObject

@property (copy, nonatomic) NSString *imdbID;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *imdbDescription;
@property (assign, nonatomic) BOOL popular;
@property (assign, nonatomic) BOOL exact;

- (id)initWithJSON:(NSDictionary *)jsonData;
- (void)parseJSON:(NSDictionary *)jsonData;

@end
