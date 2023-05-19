//
//  IMDBViewController.h
//  OroosoLibTest
//
//  Created by Rodrigo Sieiro on 27/09/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

@interface IMDBViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *searchField;
@property (strong, nonatomic) IBOutlet UILabel *resultsLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)matchTitles:(id)sender;
- (IBAction)matchPeople:(id)sender;
- (IBAction)goBack:(id)sender;

@end
