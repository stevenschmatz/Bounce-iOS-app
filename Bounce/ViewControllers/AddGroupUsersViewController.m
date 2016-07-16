//
//  HomePointGroupsViewController.m
//  bounce
//
//  Created by Robin Mehta on 3/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "AddGroupUsersViewController.h"
#import "AppConstant.h"
#import "HomePointSuccessfulCreationViewController.h"
#import <Parse/Parse.h>
#import "AppConstant.h"
#import "ParseManager.h"
#import "Utility.h"
#import "UIView+AutoLayout.h"
#import "membersCell.h"
#import "pushnotification.h"

#define ResultsTableView self.searchResultsTableViewController.tableView
#define Identifier @"Cell"

@interface AddGroupUsersViewController ()

@property (nonatomic, strong) NSArray *searchResults;

@property (nonatomic, strong) UISearchController *searchController;
@property (strong, nonatomic) UITableViewController *searchResultsTableViewController;
@property (nonatomic) NSInteger index;

@end

@implementation AddGroupUsersViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *customButton = [[Utility getInstance] createCustomButton:[UIImage imageNamed:@"common_back_button"]];
    [customButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customButton];
    
    self.searchResults = [NSMutableArray new];
    self.selectedUsers = [NSMutableArray new];
    self.index = -1;
    
        UILabel *navLabel = [UILabel new];
        navLabel.textColor = [UIColor whiteColor];
        navLabel.backgroundColor = [UIColor clearColor];
        navLabel.textAlignment = NSTextAlignmentCenter;
        navLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:20];
        self.navigationItem.titleView = navLabel;
        navLabel.text = @"Add roommates";
        [navLabel sizeToFit];
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                       initWithTitle:@"Done"
                                       style:UIBarButtonItemStylePlain
                                       target:self
                                       action:@selector(doneButtonClicked)];
        
        doneButton.tintColor = [UIColor whiteColor];
        self.navigationItem.rightBarButtonItem = doneButton;
    
    UITableView *searchResultsTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height - TAB_BAR_HEIGHT)];
    searchResultsTableView.dataSource = self;
    searchResultsTableView.delegate = self;
    
    self.searchResultsTableViewController = [[UITableViewController alloc] init];
    self.searchResultsTableViewController.tableView = searchResultsTableView;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsTableViewController];
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    
    self.searchController.searchBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.searchController.searchBar.placeholder = @"Search for a Bounce user's name";
    self.searchController.searchBar.barTintColor = BounceRed;
    self.searchController.searchBar.tintColor = [UIColor whiteColor];
    self.searchController.searchBar.layer.borderColor = [[UIColor clearColor] CGColor];
    
    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    
    self.definesPresentationContext = YES;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)cancelButtonClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)doneButtonClicked{
    if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
        //[[Utility getInstance] showProgressHudWithMessage:@"Saving..." withView:self.view];
        
        [[ParseManager getInstance] setAddGroupdelegate:self];

        [self.selectedUsers addObject:[PFUser currentUser]];
        [[ParseManager getInstance] addGroup:self.groupName withArrayOfUser:self.selectedUsers withLocation:self.groupLocation withImage:self.homepointImage withAddress:self.address];
        
        HomePointSuccessfulCreationViewController* homePointSuccessfulCreationViewController = [HomePointSuccessfulCreationViewController new];
        [self.navigationController pushViewController:homePointSuccessfulCreationViewController animated:YES];
    
//            [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:ResultsTableView]) {
        if (self.searchResults) {
            return self.searchResults.count;
        } else {
            return 0;
        }
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellId = Identifier;
    membersCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [membersCell new];
    }
    
    NSString *text;
    if ([tableView isEqual:ResultsTableView]) {
        text = [self.searchResults[indexPath.row] objectForKey:@"username"];
        
        PFUser *user = [self.searchResults objectAtIndex:indexPath.row];
        PFFile *file = [user objectForKey:@"picture"];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                cell.profileImage.image = image;
            }
        }];
    }
    
    UIImage *img = [UIImage imageNamed:@"addUser"];
    [cell.iconView setImage:img forState:UIControlStateNormal];
    
    if (indexPath.row == self.index) {
        UIImage *img = [UIImage imageNamed:@"confirmRequest"];
        [cell.iconView setImage:img forState:UIControlStateNormal];
    }
    
    [cell.iconView addTarget:self action:@selector(addMember:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.name.text = text;
    
    return cell;
}

- (void) addMember:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [ResultsTableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil) {
        PFUser *user = [self.searchResults objectAtIndex:indexPath.row];
        if (self.index != indexPath.row) {
            self.index = indexPath.row;
            [self.selectedUsers addObject:user];
            SendAddedMemberPush(self.groupName, user);
        }
        else {
            self.index = -1;
            for (int i = 0; i < [self.selectedUsers count]; i++) {
                if ([[self.selectedUsers objectAtIndex:i] isEqual:user]) {
                    [self.selectedUsers removeObjectAtIndex:i];
                }
            }
        }
        [ResultsTableView reloadData];
    }
}


#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

#pragma mark - Parse Manger Add Group delegate
- (void)didAddGroupWithError:(NSError *)error {
//    @try {
//        [[Utility getInstance] hideProgressHud];
//        if (!error) {
//            HomePointSuccessfulCreationViewController* homePointSuccessfulCreationViewController = [HomePointSuccessfulCreationViewController new];
//            [self.navigationController pushViewController:homePointSuccessfulCreationViewController animated:YES];
//        }
//    }
//    @catch (NSException *exception) {
//        NSLog(@"Exception %@", exception);
//    }
}

#pragma mark - Search Results Updating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    self.index = -1;
    UISearchBar *searchBar = searchController.searchBar;
    if (searchBar.text.length > 0) {
        NSString *text = searchBar.text;
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PFUser *user, NSDictionary *bindings) {
            NSRange range = [user.username rangeOfString:text options:NSCaseInsensitiveSearch];
            
            return range.location != NSNotFound;
        }];
        
        NSArray *searchResults = [self.candidateUsers filteredArrayUsingPredicate:predicate];
        self.searchResults = searchResults;
        
        [self.searchResultsTableViewController.tableView reloadData];
    }
}

@end
