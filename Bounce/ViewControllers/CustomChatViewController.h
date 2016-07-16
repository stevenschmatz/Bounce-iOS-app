//
//  ChatViewController.h
//  bounce
//
//  Created by Robin Mehta on 3/29/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatView.h"
#import <Parse/Parse.h>

@interface CustomChatViewController : ChatView <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) id delegate;
@property (weak, nonatomic) UITableView *tableView;
@end
