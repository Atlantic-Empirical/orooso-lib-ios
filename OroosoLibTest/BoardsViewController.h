//
//  BoardsViewController.h
//  OroosoLibTest
//
//  Created by Rodrigo Sieiro on 28/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BoardsViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextField *boardName;
@property (nonatomic, strong) IBOutlet UITextField *boardId;
@property (nonatomic, strong) IBOutlet UITextField *itemId;

- (IBAction)listBoards:(id)sender;
- (IBAction)createBoard:(id)sender;
- (IBAction)deleteBoard:(id)sender;
- (IBAction)listItems:(id)sender;
- (IBAction)addItem:(id)sender;
- (IBAction)deleteItem:(id)sender;

@end
