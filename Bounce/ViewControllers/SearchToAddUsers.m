//
//  SearchToAddUsers.m
//  bounce
//
//  Created by Robin Mehta on 8/15/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "SearchToAddUsers.h"
#import "UIView+AutoLayout.h"
#import "membersCell.h"
#import "Utility.h"
#import "pushnotification.h"
#import "AppConstant.h"
#import "usersCell.h"

#define ResultsTableView self.searchResultsTableViewController.tableView

#define Identifier @"Cell"

@interface SearchToAddUsers ()

@property (nonatomic, strong) NSArray *searchResults;

@property (nonatomic, strong) UISearchController *searchController;
@property (strong, nonatomic) UITableViewController *searchResultsTableViewController;
@property (nonatomic) NSInteger index;

@end

@implementation SearchToAddUsers

- (void)viewDidLoad {
        [super viewDidLoad];
    
        UIButton *customButton = [[Utility getInstance] createCustomButton:[UIImage imageNamed:@"common_back_button"]];
        [customButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customButton];

        self.searchResults = [NSMutableArray new];
        self.index = -1;
    
       UILabel *navLabel = [UILabel new];
        navLabel.textColor = [UIColor whiteColor];
        navLabel.backgroundColor = [UIColor clearColor];
        navLabel.textAlignment = NSTextAlignmentCenter;
        navLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:20];
       self.navigationItem.titleView = navLabel;
        navLabel.text = @"Search for Users";
        [navLabel sizeToFit];
    
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
    self.searchController.searchBar.placeholder = @"Search a Bounce user's name";
    self.searchController.searchBar.barTintColor = BounceRed;
    self.searchController.searchBar.tintColor = [UIColor whiteColor];
    self.searchController.searchBar.layer.borderColor = [[UIColor clearColor] CGColor];
    
    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    
        self.definesPresentationContext = YES;
}

- (void)viewDidAppear:(BOOL)animated {
        [super viewDidAppear:animated];
}

- (void)cancelButtonClicked {
        [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table View Data Source
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
        usersCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    
        if (!cell) {
                cell = [usersCell new];
            }
    
        NSString *text;
        if ([tableView isEqual:ResultsTableView]) {
                text = [self.searchResults[indexPath.row] objectForKey:@"username"];
        }
    
        UIImage *img = [UIImage imageNamed:@"addUser"];
        [cell.iconView setImage:img forState:UIControlStateNormal];
        cell.iconView.tag = indexPath.row;
        if (indexPath.row == self.index) {
                UIImage *img = [UIImage imageNamed:@"confirmRequest"];
                [cell.iconView setImage:img forState:UIControlStateNormal];
           }
    
        [cell.iconView addTarget:self action:@selector(addMember:) forControlEvents:UIControlEventTouchUpInside];
    
        cell.name.text = text;
    
    PFUser *user = [self.searchResults objectAtIndex:indexPath.row];
    PFFile *file = [user objectForKey:@"picture"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            cell.profileImage.image = image;
        }
    }];
       return cell;
}

- (void) addMember:(id)sender {
    
    UIButton *senderButton = (UIButton *)sender;
    NSIndexPath *path = [NSIndexPath indexPathForRow:senderButton.tag inSection:0];
        if (path != nil) {
                PFUser *user = [self.searchResults objectAtIndex:path.row];
               if (self.index != path.row) {
                        self.index = path.row;
                        [[ParseManager getInstance] addUser:user toGroup:self.group];
                   SendAddedMemberPush([self.group valueForKey:@"groupName"], user);
                    }
                else {
                        self.index = -1;
                        NSArray *userArray = [[NSArray alloc] initWithObjects:user, nil];
                        [[ParseManager getInstance] addListOfUsers:nil toGroup:self.group andRemove:userArray];
                    }
                [ResultsTableView reloadData];
            }
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        //[tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        return 100;
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