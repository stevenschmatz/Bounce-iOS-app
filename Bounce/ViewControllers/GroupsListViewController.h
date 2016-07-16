//
//  GroupsListViewController.h
//  bounce
//
//  Created by Robin Mehta on 3/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseManager.h"

@interface GroupsListViewController : UIViewController<
    UITableViewDelegate,
    UITableViewDataSource,
    ParseManagerLoadingGroupsDelegate,
    ParseManagerGetUserGroups,
    ParseManagerDeleteDelegate>

@property NSMutableArray* groups;
@property NSMutableArray *nearUsers;
@property NSMutableArray *distanceToUserLocation;
@property (weak, nonatomic) UITableView *tableView;

// A RootTabBarController delegate
@property (strong, nonatomic) id delegate;

@end
