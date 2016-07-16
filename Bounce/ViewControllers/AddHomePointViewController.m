//
//  AddHomePointViewController.m
//  bounce
//
//  Created by Robin Mehta on 3/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "AddHomePointViewController.h"
#import "AppConstant.h"
#import "AddGroupUsersViewController.h"
#import <Parse/Parse.h>
#import "GroupsListViewController.h"
#import "Utility.h"
#import "Constants.h"
#import "AddGroupUsersViewController.h"
#import "AddLocationScreenViewController.h"
#import "CreateHomepoint.h"
#import "UIView+AutoLayout.h"
#import "homepointListCell.h"
#import "membersCell.h"
#import "UINavigationBar+Addition.h"
#import "pushnotification.h"

#define ResultsTableView self.searchResultsTableViewController.tableView
#define Identifier @"Cell"

@interface AddHomePointViewController ()

@property (nonatomic) NSInteger cellIndex;
//////////////
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) UISearchController *searchController;
@property (strong, nonatomic) UITableViewController *searchResultsTableViewController;
@property (nonatomic) NSInteger index;
@property (nonatomic, strong) PFObject *currentGroup;
@property (nonatomic) BOOL shouldAdd;

@property (nonatomic, strong) NSArray *friendIds;

@end

@implementation AddHomePointViewController
{
    NSMutableArray *groups;
    NSMutableArray *groupsDistance;
    NSMutableArray *userJoinedGroups;
    NSInteger selectedIndex;
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.allGroups = [NSArray new];
    self.searchResults = [NSMutableArray new];
    self.index = -1;
    self.shouldAdd = NO;
    
    UILabel *navLabel = [UILabel new];
    navLabel.textColor = [UIColor whiteColor];
    navLabel.backgroundColor = [UIColor clearColor];
    navLabel.textAlignment = NSTextAlignmentCenter;
    navLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:20];
    self.navigationItem.titleView = navLabel;
    navLabel.text = @"Add Homepoint";
    [navLabel sizeToFit];
    
    UIBarButtonItem *createButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"createIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(createButtonClicked)];
    createButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = createButton;
    
    UIButton *customButton = [[Utility getInstance] createCustomButton:[UIImage imageNamed:@"common_back_button"]];
    [customButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customButton];
    
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
    self.searchController.searchBar.placeholder = @"Search a homepoint's name or neighborhood";
    self.searchController.searchBar.barTintColor = BounceRed;
    self.searchController.searchBar.tintColor = [UIColor whiteColor];
    self.searchController.searchBar.layer.borderColor = [[UIColor clearColor] CGColor];
    
    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    
    self.definesPresentationContext = YES;
}

-(void)createButtonClicked {
    //    [[Utility getInstance] showProgressHudWithMessage:@"Loading"];
    //    [[ParseManager getInstance] setGetAllOtherGroupsDelegate:self];
    //    [[ParseManager getInstance] getAllOtherGroupsForCurrentUser];
    
    @try {
        CreateHomepoint *createhomepoint = [CreateHomepoint new];
        [self.navigationController pushViewController:createhomepoint animated:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[Utility getInstance] showProgressHudWithMessage:@"Loading"];
    [[ParseManager getInstance] setGetAllOtherGroupsDelegate:self];
    [[ParseManager getInstance] getAllOtherGroupsForCurrentUser];
    [[ParseManager getInstance] setUpdateGroupDelegate:self];
    [[ParseManager getInstance] setGetFacebookFriendsDelegate:self];
    [self loadGroups];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - load groups
- (void) loadGroups
{
    @try {
        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
            [[Utility getInstance] showProgressHudWithMessage:@"Loading..." withView:self.view];
            [[ParseManager getInstance] setLoadGroupsdelegate:self];
            [[ParseManager getInstance] getCandidateGroupsForCurrentUser];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}
#pragma mark - Parse Loading Groups Manager Delegate
- (void)didLoadGroups:(NSArray *)objects withError:(NSError *)error
{
    @try {
        [[Utility getInstance] hideProgressHud];
        if (!error) {
            groups = [[NSMutableArray alloc] initWithArray:objects];
            [[ParseManager getInstance] getFacebookFriends];
            groupsDistance = [[NSMutableArray alloc] init];
            userJoinedGroups = [[NSMutableArray alloc] init];
            self.homepointImages = [NSMutableArray new];
            
            for (PFObject *group in groups) {
                [groupsDistance addObject:[NSNumber numberWithDouble:[[ParseManager getInstance] getDistanceToGroup:group]]];
                [userJoinedGroups addObject:[NSNumber numberWithBool:NO]];
                
                if ([group valueForKey:PF_GROUP_IMAGE]) {
                    [self.homepointImages addObject:[group valueForKey:PF_GROUP_IMAGE]];
                }
            }
            [[ParseManager getInstance] getFacebookFriends];
            [[Utility getInstance] hideProgressHud];
            [self.tableView reloadData];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

- (void)didLoadAllOtherGroups:(NSArray *)allGroups {
    [[Utility getInstance] hideProgressHud];
    self.allGroups = allGroups;
}

-(void)cancelButtonClicked{
    [self.navigationController popViewControllerAnimated:YES];
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
        return [groups count];
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
        text = [self.searchResults[indexPath.row] objectForKey:@"groupName"];
        cell.friendsLabel.text = @"Loading...";
        
        PFObject *homepoint = self.searchResults[indexPath.row];
        cell.group = homepoint;
        PFRelation *groupUsers = homepoint[PF_GROUP_Users_RELATION];
        PFQuery *friendsQuery = [groupUsers query];
        PFQuery *totalQuery = [groupUsers query];
        [friendsQuery whereKey:@"facebookId" containedIn:self.friendIds];
        
        [friendsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            // Gets friend count
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.friendsLabel.text = [NSString stringWithFormat:@"%lu friends, ", (unsigned long)[objects count]];
            });
            
            [totalQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                // Gets total number
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.friendsLabel.text = [cell.friendsLabel.text stringByAppendingString:[NSString stringWithFormat:@"%lu total", (unsigned long)[objects count]]];
                });
            }];
        }];
    
        cell.address.text = [self.searchResults[indexPath.row] objectForKey:@"Address"];

        cell.name.text = text;
        PFObject *hp = [self.searchResults objectAtIndex:indexPath.row];
        PFFile *file = [hp objectForKey:PF_GROUP_IMAGE];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                cell.profileImage.image = image;
            }
        }];
    }
    else {
        text = [groups[indexPath.row] objectForKey:@"groupName"];
        PFObject *homepoint = groups[indexPath.row];
        cell.group = homepoint;
        
        cell.friendsLabel.text = @"Loading...";
        if ([self.allGroups count]) {
        //PFObject *homepoint = self.allGroups[indexPath.row];
        PFRelation *groupUsers = homepoint[PF_GROUP_Users_RELATION];
        PFQuery *friendsQuery = [groupUsers query];
        PFQuery *totalQuery = [groupUsers query];
        [friendsQuery whereKey:@"facebookId" containedIn:self.friendIds];
        
        [friendsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            // Gets friend count
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.friendsLabel.text = [NSString stringWithFormat:@"%lu friends, ", (unsigned long)[objects count]];
            });
            
            [totalQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                // Gets total number
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.friendsLabel.text = [cell.friendsLabel.text stringByAppendingString:[NSString stringWithFormat:@"%lu total", (unsigned long)[objects count]]];
                });
            }];
        }];
        }

        
        cell.address.text = [groups[indexPath.row] objectForKey:@"Address"];
        
        cell.name.text = text;
        PFObject *hp = [groups objectAtIndex:indexPath.row];
        PFFile *file = [hp objectForKey:PF_GROUP_IMAGE];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                cell.profileImage.image = image;
            }
        }];
    }
    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 140;
}

#pragma mark - Delete user from selected group
- (void) deleteUserFromGroup:(NSInteger) index
{
    @try {
        PFObject *group = [groups objectAtIndex:index];
        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
            [[Utility getInstance] showProgressHudWithMessage:[NSString stringWithFormat:@"removed from %@", [group objectForKey:PF_GROUPS_NAME]] withView:self.view];
            selectedIndex = index;
            [[ParseManager getInstance] getTentativeUsersFromGroup:group];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - Parse Manager Update Group delegate
- (void)didRemoveUserFromGroup:(BOOL)succeed
{
    [[Utility getInstance] hideProgressHud];
    if (succeed) {
        // update group cell
        [userJoinedGroups insertObject:[NSNumber numberWithBool:NO] atIndex:selectedIndex];
        [self updateRowAtIndex:selectedIndex];
    }
}

- (void)didAddUserToGroup:(BOOL)succeed
{
    [[Utility getInstance] hideProgressHud];
    if (succeed) {
        // update group cell
        [userJoinedGroups insertObject:[NSNumber numberWithBool:YES] atIndex:selectedIndex];
        [self updateRowAtIndex:selectedIndex];
    }
}

#pragma mark - update Row
- (void) updateRowAtIndex:(NSInteger) index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}

#pragma mark - Parse Manager Delegate
- (void)didloadAllObjects:(NSArray *)objects
{
    [[Utility getInstance] hideProgressHud];
    NSMutableArray *users  = [[NSMutableArray alloc] initWithArray:objects];
    PFUser *currentUser = [PFUser currentUser];
    // Add the current user to the first cell
    [users insertObject:currentUser atIndex:0];
}
- (void)didFailWithError:(NSError *)error
{
    [[Utility getInstance] hideProgressHud];
}

#pragma mark - Search Results Updating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    self.index = -1;
    UISearchBar *searchBar = searchController.searchBar;
    if (searchBar.text.length > 0) {
        NSString *text = searchBar.text;
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PFObject *group, NSDictionary *bindings) {
            NSRange range = [group[@"groupName"] rangeOfString:text options:NSCaseInsensitiveSearch];
            return range.location != NSNotFound;
        }];
        
        NSPredicate *addressPredicate = [NSPredicate predicateWithBlock:^BOOL(PFObject *group, NSDictionary *bindings) {
            NSRange range = [group[@"Address"] rangeOfString:text options:NSCaseInsensitiveSearch];
            return range.location != NSNotFound;
        }];
        
        NSPredicate *compoundPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[predicate, addressPredicate]];
        
        NSArray *searchResults = [self.allGroups filteredArrayUsingPredicate:compoundPredicate];
        searchResults = [searchResults sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSUInteger location1 = MIN([obj1[@"groupName"] rangeOfString:text options:NSCaseInsensitiveSearch].location,
                                       [obj1[@"Address"] rangeOfString:text options:NSCaseInsensitiveSearch].location);
            NSUInteger location2 = MIN([obj2[@"groupName"] rangeOfString:text options:NSCaseInsensitiveSearch].location,
                                       [obj2[@"Address"] rangeOfString:text options:NSCaseInsensitiveSearch].location);
            if (location1 < location2) {
                return NSOrderedAscending;
            } else if (location2 < location1) {
                return NSOrderedDescending;
            }
            return NSOrderedSame;
        }];
        
        self.searchResults = searchResults;
        [self.searchResultsTableViewController.tableView reloadData];
    }
}

- (void) didLoadFacebookFriends:(NSArray *)friends withError:(NSError *)error {
    
    NSMutableArray *friendIds = [[NSMutableArray alloc] init];
    for (PFObject *friend in friends) {
        [friendIds addObject:friend[@"id"]];
    }
    
    self.friendIds = friendIds;
    [self.tableView reloadData];
    
}

@end
