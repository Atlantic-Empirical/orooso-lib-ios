//
//  IMDBViewController.m
//  OroosoLibTest
//
//  Created by Rodrigo Sieiro on 27/09/12.
//  Copyright (c) 2012 Orooso, Inc. All rights reserved.
//

#import "IMDBViewController.h"

@interface IMDBViewController ()

@property (nonatomic, strong) ORIMDBEngine *imdbEngine;
@property (nonatomic, strong) NSArray *tableData;
@property (nonatomic, assign) BOOL dataIsPerson;

- (void)showMessage:(NSString *)message;

@end

@implementation IMDBViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imdbEngine = [[ORIMDBEngine alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [self setSearchField:nil];
    [self setResultsLabel:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - UITableView data source and delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellID = @"cellID";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
    if (self.dataIsPerson) {
        ORIMDBPerson *item = [self.tableData objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", item.name, item.imdbDescription];
    } else {
        ORIMDBTitle *item = [self.tableData objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", item.title, item.imdbDescription];
    }
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataIsPerson) {
        ORIMDBPerson *item = [self.tableData objectAtIndex:indexPath.row];
        NSLog(@"Selected: %@", item);
    } else {
        ORIMDBTitle *item = [self.tableData objectAtIndex:indexPath.row];
        NSLog(@"Selected: %@", item);
    }
}

#pragma mark - Custom Methods

- (void)showMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Demo"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (IBAction)matchTitles:(id)sender
{
    [self.searchField resignFirstResponder];
    
    [self.imdbEngine matchTitlesForString:self.searchField.text cb:^(NSError *error, NSArray *items) {
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            if (!items || [items count] == 0) {
                [self showMessage:@"No results found"];
                return;
            }
            
            self.resultsLabel.text = [NSString stringWithFormat:@"%d Titles found:", [items count]];
            self.dataIsPerson = NO;
            self.tableData = items;
            [self.tableView reloadData];
        }
    }];
}

- (IBAction)matchPeople:(id)sender
{
    [self.searchField resignFirstResponder];
    
    [self.imdbEngine matchPeopleForString:self.searchField.text cb:^(NSError *error, NSArray *items) {
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            if (!items || [items count] == 0) {
                [self showMessage:@"No results found"];
                return;
            }
            
            self.resultsLabel.text = [NSString stringWithFormat:@"%d Persons found:", [items count]];
            self.dataIsPerson = YES;
            self.tableData = items;
            [self.tableView reloadData];
        }
    }];
}

- (IBAction)goBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
