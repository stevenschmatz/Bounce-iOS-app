//
//  GroupsListViewController.m
//  bounce
//
//  Created by Robin Mehta on 3/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "GroupsListViewController.h"
#import "AddHomePointViewController.h"
#import "AppConstant.h"
#import "Utility.h"
#import "Constants.h"
#import "HomeScreenViewController.h"
#import "AddGroupUsersViewController.h"
#import "bounce-Swift.h"
#import "homepointListCell.h"
#import "MembersViewController.h"
#import "HomepointChat.h"
#import <FacebookSDK/FBRequestConnection.h>


@interface GroupsListViewController ()

@property NSArray *images;
@property BOOL firstDone;
@end

@implementation GroupsListViewController
{
    BOOL loadingData;
    NSInteger selectedIndex;
    NSMutableArray *groupUsers;
    NSArray *tentative_users;
    
    // Placeholder content
    UIImageView *placeholderImageView;
    UILabel *placeholderTitle;
    UILabel *placeholderBodyText;
}

@synthesize distanceToUserLocation = distanceToUserLocation;

- (id)initWithDelegate:(id<RootTabBarControllerDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.firstDone = NO;
    self.navigationController.navigationBar.barTintColor = BounceRed;
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar hideBottomHairline];

    UITableView *tableView = [UITableView new];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    _tableView = tableView;
    [tableView kgn_sizeToWidth:self.view.frame.size.width];
    [tableView kgn_pinToTopEdgeOfSuperview];
    [tableView kgn_pinToBottomEdgeOfSuperviewWithOffset:TAB_BAR_HEIGHT];
    [tableView kgn_pinToLeftEdgeOfSuperview];

    UIView *backgroundView = [UIView new];
    backgroundView.frame = self.view.frame;
    backgroundView.backgroundColor = BounceRed;
    [self.tableView setBackgroundView:backgroundView];
    
    UIButton *rightButton = [[Utility getInstance] createCustomButton:[UIImage imageNamed:@"Plus"]];
    [rightButton addTarget:self action:@selector(addButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    UILabel *navLabel = [UILabel new];
    navLabel.textColor = [UIColor whiteColor];
    navLabel.backgroundColor = [UIColor clearColor];
    navLabel.textAlignment = NSTextAlignmentCenter;
    navLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:21];
    self.navigationItem.titleView = navLabel;
    navLabel.text = @"Homepoints";
    [navLabel sizeToFit];
    
    UIView *whiteCoverView = [UIView new];
    whiteCoverView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:whiteCoverView];
    [whiteCoverView kgn_pinToBottomEdgeOfSuperview];
    [whiteCoverView kgn_pinToSideEdgesOfSuperview];
    [whiteCoverView kgn_sizeToHeight:TAB_BAR_HEIGHT];
}

#pragma mark Placeholder Methods

/**
 * Renders the placeholder image and text when the user has no homepoints.
 */
- (void)showPlaceholder {
    if (placeholderImageView == nil) {
        placeholderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Homepoints-Placeholder"]];
        [self.tableView.backgroundView addSubview:placeholderImageView];
        [placeholderImageView kgn_pinToTopEdgeOfSuperviewWithOffset:50];
        [placeholderImageView kgn_centerHorizontallyInSuperview];
        [placeholderImageView kgn_sizeToWidthAndHeight:self.view.frame.size.width * 0.6];
    } else {
        placeholderImageView.hidden = false;
    }
    
    if (placeholderTitle == nil) {
        placeholderTitle = [UILabel new];
        placeholderTitle.text = @"Add your first homepoint.";
        placeholderTitle.textColor = [UIColor whiteColor];
        placeholderTitle.textAlignment = NSTextAlignmentCenter;
        placeholderTitle.font = [UIFont fontWithName:@"AvenirNext-Medium" size:23];
        [self.tableView.backgroundView addSubview:placeholderTitle];
        [placeholderTitle kgn_positionBelowItem:placeholderImageView withOffset:30];
        [placeholderTitle kgn_centerHorizontallyInSuperview];
    } else {
        placeholderTitle.hidden = false;
    }
    
    if (placeholderBodyText == nil) {
        placeholderBodyText = [UILabel new];
        placeholderBodyText.text = @"Search for communities nearby – join or create homepoints for your house, apartment, dorm, or neighborhood.";
        placeholderBodyText.textColor = [UIColor whiteColor];
        placeholderBodyText.textAlignment = NSTextAlignmentCenter;
        placeholderBodyText.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18];
        placeholderBodyText.numberOfLines = 0;
        placeholderBodyText.lineBreakMode = NSLineBreakByWordWrapping;
        [self.tableView.backgroundView addSubview:placeholderBodyText];
        [placeholderBodyText kgn_positionBelowItem:placeholderTitle withOffset:30];
        [placeholderBodyText kgn_pinToSideEdgesOfSuperviewWithOffset:10];
        
        if (self.view.frame.size.height <= 480) {
            placeholderBodyText.hidden = true;
        }
    } else {
        if (self.view.frame.size.height <= 480) {
            placeholderBodyText.hidden = true;
        } else {
            placeholderBodyText.hidden = false;
        }
    }
}

/**
 * Hides the placeholder image and text when the user has one or more homepoints.
 */
- (void)hidePlaceholder {
    if (placeholderImageView) {
        [placeholderImageView removeFromSuperview];
    }
    if (placeholderTitle) {
        [placeholderTitle removeFromSuperview];
    }
    if (placeholderBodyText) {
        [placeholderBodyText removeFromSuperview];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    [self.delegate setHomepointNotification:false];

    @try {
        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
            //[[Utility getInstance] showProgressHudWithMessage:@"Loading..." withView:self.view];
            
//            PFQuery *query = [PFQuery queryWithClassName:PF_GROUPS_CLASS_NAME];
//            [query whereKey:PF_GROUP_Users_RELATION equalTo:[PFUser currentUser]];
//            [query includeKey:PF_GROUP_OWNER];
//            
//            [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
//                    if (number == 0) {
//                        [self showPlaceholder];
//                    } else {
//                        [self hidePlaceholder];
//                    }
//            }];
            
            [[ParseManager getInstance] setGetUserGroupsdelegate:self];
            loadingData = YES;
            [[ParseManager getInstance] getUserGroups];
            [[ParseManager getInstance] getFacebookFriends];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception);
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)backButtonClicked {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)addButtonClicked{
    if (!loadingData) {
        AddHomePointViewController* addHomePointViewController = [AddHomePointViewController new];
        [self.navigationController pushViewController:addHomePointViewController animated:YES];
    }
}
#pragma mark - Parse LoadGroups delegate
- (void)didLoadUserGroups:(NSArray *)groups WithError:(NSError *)error
{
    @try {
        if (error) {
            [[Utility getInstance] hideProgressHud];
            loadingData = NO;
        }else{
            if ([groups count] == 0) {
                [[Utility getInstance] hideProgressHud];
                [self showPlaceholder];
            }
            else {
                if (placeholderImageView != nil) {
                    [placeholderImageView removeFromSuperview];
                    [placeholderBodyText removeFromSuperview];
                    [placeholderTitle removeFromSuperview];
                }
            }
            if(!self.groups)
            {
                self.groups = [[NSMutableArray alloc] init];
            }
            self.groups = [NSMutableArray arrayWithArray:groups];
            // calculate the near users in each group
            // calcultae the distance to the group

            distanceToUserLocation = [[NSMutableArray alloc] init];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (PFObject *group in groups) {
                    // Get distance label
                    double distance = [[ParseManager getInstance] getDistanceToGroup:group];
                    NSString *distanceLabel = @"";
                    
                    if (distance > 2500) {
                        distance = distance*0.000189394;
                        
                        if (distance >= 500) {
                            distanceLabel = @"500+ miles away";
                        }
                        
                        else {
                            distanceLabel = [NSString stringWithFormat:DISTANCE_MESSAGE_IN_MILES, distance];
                        }
                    }
                    else {
                        if (distance <= 200) {
                            distanceLabel = @"You are here";
                        }
                        else {
                        distanceLabel = [NSString stringWithFormat:DISTANCE_MESSAGE_IN_FEET, (int)distance];
                        }
                    }
                    
                    [self.distanceToUserLocation addObject:distanceLabel];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Update the UI on the main thread.
                    [[Utility getInstance] hideProgressHud];
                    [self.tableView reloadData];
                    loadingData = NO;
                });
            });
        }
    }
    @catch (NSException *exception) {
        
    }
}

- (void)didLoadGroups:(NSArray *)groups withError:(NSError *)error
{
    @try {
        if (error) {
            [[Utility getInstance] hideProgressHud];
            loadingData = NO;
        }else{
            if(!self.groups)
            {
                self.groups = [[NSMutableArray alloc] init];
            }
            self.groups = [NSMutableArray arrayWithArray:groups];
            // calculate the near users in each group
            // calcultae the distance to the group

//            self.distanceToUserLocation = [[NSMutableArray alloc] init];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Update the UI on the main thread.
                    [[Utility getInstance] hideProgressHud];
                    [self.tableView reloadData];
                    loadingData = NO;
                });
            });
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception);
    }
}

#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.groups count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
            [[Utility getInstance] showProgressHudWithMessage:@"Deleting..." withView:self.view];
            selectedIndex = indexPath.row;
            [[ParseManager getInstance] setDeleteDelegate:self];
            [[ParseManager getInstance] deleteGroup:[self.groups objectAtIndex:selectedIndex]];
            [tableView reloadData];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellId = @"homepointListCell";
    HomepointListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [HomepointListCell new];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if ([self.groups count] > indexPath.row) {
        cell.backgroundColor = [UIColor grayColor];
        PFFile *file = [[self.groups objectAtIndex:indexPath.row] objectForKey:@"groupImage"];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                    UIImage *image = [UIImage imageWithData:data];
                    [cell setBackground:image];
                    cell.backgroundView.alpha = 0.0;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [UIView animateWithDuration:0.25f animations:^{
                            cell.backgroundView.alpha = 1.0f;
                        }];
                    });
            }
        }];
    }
    //}
    
    if ([self.groups count] > indexPath.row) {
        NSString *homepointName = [[[self.groups objectAtIndex:indexPath.row] objectForKey:PF_GROUPS_NAME] uppercaseString];
        [cell setName:homepointName homepointType: HomepointTypeHouse];
    }
    
    if ([self.distanceToUserLocation count] > indexPath.row) {
        NSString *distanceText = [self.distanceToUserLocation objectAtIndex:indexPath.row];
        
        [cell setDistance:distanceText];
    }
    
    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedIndex = indexPath.row;
    [self editGroupUsers:[self.groups objectAtIndex:indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.frame.size.height/2.5;
}

#pragma mark - Parse Manger delete delegate
- (void)didDeleteObject:(BOOL)succeeded
{
    @try {
        [[Utility getInstance] hideProgressHud];
        if (succeeded) {
            [self.groups removeObjectAtIndex:selectedIndex];
            [distanceToUserLocation removeObjectAtIndex:selectedIndex];
            [self.tableView reloadData];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - Edit User group
- (void) editGroupUsers:(PFObject *) group
{
    if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
        NSString *requestId = group.objectId;
        
        [[ParseManager getInstance] createMessageItemForUser:[PFUser currentUser] WithGroupId:requestId andDescription:[group objectForKey:@"groupName"]];
        
        HomepointChat *chat = [[HomepointChat alloc] initWith:requestId];
        chat.rootTabBarDelegate = self.delegate;
        chat.homepoint = group;
        chat.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chat animated:YES];
    }
}

@end
