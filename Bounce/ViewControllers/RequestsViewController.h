//
//  GroupsListViewController.h
//  ChattingApp
//
//  Created by Robin Mehta on 3/18/15.
//  Copyright (c) 2015 Bounce Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "ParseManager.h"

#pragma mark RequestsViewControllerDelegate

@class RequestsViewController;
@protocol RequestsViewControllerDelegate <NSObject>
@required

- (void) requestsViewControllerDidRequestDismissal:(RequestsViewController *)controller withCompletion:(void (^) ())completion;

@end

#pragma mark RequestsViewController

@interface RequestsViewController : UIViewController<ParseManagerDelegate, ParseManagerDeleteDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, ParseManagerGetFacebookFriendsDelegate>

@property (strong, nonatomic) id delegate;
@property (weak, nonatomic) UITableView *requestsTableView;
@property (strong, nonatomic) NSMutableArray *images;
@property (weak, nonatomic) UIView *bottomView;

@property (nonatomic, strong) UIAlertController *imageActionSheet;

@property (nonatomic, strong) NSArray *friendIds;

@end
