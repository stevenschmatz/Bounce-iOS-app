//
//  AddUsersViewController.h
//  bounce
//
//  Created by Robin Mehta on 8/13/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseManager.h"
#import "AddGroupUsersViewController.h"
#import "AppConstant.h"
#import "HomePointSuccessfulCreationViewController.h"
#import <Parse/Parse.h>
#import "AppConstant.h"
#import "Utility.h"
#import "UIView+AutoLayout.h"

// This is the view for editing users (should show pending users + users in group).

@interface MembersViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ParseManagerLoadNewUsers>

@property (nonatomic, strong) PFObject *group;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *tentativeUsers;
@property (nonatomic, strong) NSArray *actualUsers;
@property (nonatomic) BOOL selected;

@end
