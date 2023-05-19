//
//  BoardsViewController.m
//  OroosoLibTest
//
//  Created by Rodrigo Sieiro on 28/06/13.
//  Copyright (c) 2013 Orooso, Inc. All rights reserved.
//

#import "BoardsViewController.h"

@interface BoardsViewController ()

@end

@implementation BoardsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)listBoards:(id)sender
{
    ORApiEngine *api = [ORApiEngine sharedInstance];
    
    [api getBoardsWithCompletion:^(NSError *error, NSArray *result) {
        if (error) {
            NSLog(@"Error: %@", error);
            return;
        }
        
        NSLog(@"Received %d results", result.count);
        
        for (ORBoard *board in result) {
            NSLog(@"Board: %@ (%@)", board.name, board.boardId);
        }
    }];
}

- (void)createBoard:(id)sender
{
    if (!self.boardName.text || [self.boardName.text isEqualToString:@""]) {
        NSLog(@"Error: Missing Board Name");
        return;
    }
    
    ORApiEngine *api = [ORApiEngine sharedInstance];
    ORBoard *board = [[ORBoard alloc] init];
    
    board.userId = api.currentUserID;
    board.name = self.boardName.text;
    board.isPublic = NO;
    
    [api saveBoard:board cb:^(NSError *error, ORBoard *board) {
        if (error) {
            NSLog(@"Error: %@", error);
            return;
        }

        NSLog(@"Board Created: %@ (%@)", board.name, board.boardId);
    }];
}

- (void)deleteBoard:(id)sender
{
    if (!self.boardId.text || [self.boardId.text isEqualToString:@""]) {
        NSLog(@"Error: Missing Board ID");
        return;
    }

    ORApiEngine *api = [ORApiEngine sharedInstance];
    
    [api deleteBoard:self.boardId.text cb:^(NSError *error, BOOL result) {
        if (error) {
            NSLog(@"Error: %@", error);
            return;
        }
        
        NSLog(@"Delete Board: %@", result ? @"Success" : @"Fail");
    }];
}

- (void)listItems:(id)sender
{
    if (!self.boardId.text || [self.boardId.text isEqualToString:@""]) {
        NSLog(@"Error: Missing Board ID");
        return;
    }

    ORApiEngine *api = [ORApiEngine sharedInstance];
    
    [api getBoardItems:self.boardId.text cb:^(NSError *error, NSArray *result) {
        if (error) {
            NSLog(@"Error: %@", error);
            return;
        }
        
        NSLog(@"Received %d results", result.count);
        
        for (ORBoardItem *item in result) {
            NSLog(@"Item: %@ (%@)", item.item.title, item.item.itemID);
        }
    }];
}

- (void)addItem:(id)sender
{
    if (!self.boardId.text || [self.boardId.text isEqualToString:@""]) {
        NSLog(@"Error: Missing Board ID");
        return;
    }

    ORApiEngine *api = [ORApiEngine sharedInstance];
    ORSFItem *item = [[ORSFItem alloc] init];
    
    item.itemID = [NSString stringWithFormat:@"test_item_%ld", time(NULL)];
    item.type = SFItemTypeGeneric;
    item.title = @"Test Item Title";
    item.content = @"Test Item Content";
    item.detailURL = [ORURL URLWithURLString:@"http://www.google.com"];
    item.imageURL = [NSURL URLWithString:@"http://f0.bcbits.com/img/a2392791305_2.jpg"];
    item.avatarURL = [NSURL URLWithString:@"http://www.dynacont.net/images/24x24/user_add.png"];
    
    ORBoardItem *i = [[ORBoardItem alloc] initWithItem:item];
    i.boardId = self.boardId.text;
    
    [api saveBoardItem:i cb:^(NSError *error, NSString *itemID) {
        if (error) {
            NSLog(@"Error: %@", error);
            return;
        }
        
        NSLog(@"Item Saved: %@", itemID);
    }];
}

- (void)deleteItem:(id)sender
{
    if (!self.boardId.text || [self.boardId.text isEqualToString:@""]) {
        NSLog(@"Error: Missing Board ID");
        return;
    }

    if (!self.itemId.text || [self.itemId.text isEqualToString:@""]) {
        NSLog(@"Error: Missing Item ID");
        return;
    }
    
    ORApiEngine *api = [ORApiEngine sharedInstance];
    
    [api removeItemFromBoard:self.boardId.text itemId:self.itemId.text cb:^(NSError *error, BOOL result) {
        if (error) {
            NSLog(@"Error: %@", error);
            return;
        }
        
        NSLog(@"Delete Item: %@", result ? @"Success" : @"Fail");
    }];
}

@end
