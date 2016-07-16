//
//  AddUsersViewController.m
//  bounce
//
//  Created by Robin Mehta on 8/13/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "MembersViewController.h"
#import "membersCell.h"
#import "SearchToAddUsers.h"
#import "pushnotification.h"
#import "usersCell.h"

@implementation MembersViewController

- (void)viewDidLoad {
        [super viewDidLoad];
    
        UITableView *tableView = [UITableView new];
        tableView.dataSource = self;
       tableView.delegate = self;
       [self.view addSubview:tableView];
        _tableView = tableView;
        [_tableView kgn_pinToTopEdgeOfSuperview];
        [_tableView kgn_pinToLeftEdgeOfSuperview];
        [_tableView kgn_sizeToWidth:self.view.frame.size.width];
        [_tableView kgn_sizeToHeight:self.view.frame.size.height - 100];
    
        UIButton *customButton = [[Utility getInstance] createCustomButton:[UIImage imageNamed:@"common_back_button"]];
        [customButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customButton];
    
        UIButton *rightButton = [[Utility getInstance] createCustomButton:[UIImage imageNamed:@"Plus"]];
        [rightButton addTarget:self action:@selector(addMembersClicked) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
        UILabel *navLabel = [UILabel new];
        navLabel.textColor = [UIColor whiteColor];
        navLabel.backgroundColor = [UIColor clearColor];
        navLabel.textAlignment = NSTextAlignmentCenter;
        navLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:20];
        self.navigationItem.titleView = navLabel;
        navLabel.text = @"Members";
        [navLabel sizeToFit];
    
}

// Sets nav bar button item with image
-(UIBarButtonItem *)initialiseBarButton:(UIImage*) buttonImage withAction:(SEL) action {
    
       UIButton *buttonItem = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonItem.bounds = CGRectMake( 0, 0, buttonImage.size.width, buttonImage.size.height );
        [buttonItem addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
        [buttonItem setImage:buttonImage forState:UIControlStateNormal];
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonItem];
        return barButtonItem;
    }

- (void)addMembersClicked {
    if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
        [[Utility getInstance] showProgressHudWithMessage:@"Loading..." withView:self.view];
        [[ParseManager getInstance] setLoadNewUsers:self];
        [[ParseManager getInstance] getCandidateUsersForGroup:self.group];
    }
}

- (void) cancelButtonClicked {
        [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.tentativeUsers count] > 0) {
        return 2;
    }
    else return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.tentativeUsers count] > 0) {
        if (section == 0) {
                return [self.tentativeUsers count];
            }
       else {
               return  [self.actualUsers count];
           }
    }
    else {
        return [self.actualUsers count];
    }
}

- (BOOL)tableView:(UITableView *)tv shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
        return NO;
    }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        NSString* cellId = @"ChatListCell";
        usersCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    
        if (!cell) {
               cell = [usersCell new];
            }
    
        PFUser *user = [PFUser new];
    if ([self.tentativeUsers count] > 0) {
       if (indexPath.section == 0) {
                user = [self.tentativeUsers objectAtIndex:indexPath.row];
        
                if (!self.selected) {
                        UIImage *img = [UIImage imageNamed:@"addUser"];
                        [cell.iconView setImage:img forState:UIControlStateNormal];
                    }
                else {
                        UIImage *img = [UIImage imageNamed:@"confirmRequest"];
                       [cell.iconView setImage:img forState:UIControlStateNormal];
                    }
        
                [cell.iconView addTarget:self action:@selector(approveMember:) forControlEvents:UIControlEventTouchUpInside];
        }
       else {
                user = [self.actualUsers objectAtIndex:indexPath.row];
                cell.iconView = nil;
        }
       cell.name.text = [user objectForKey:@"username"];
    
        PFFile *file = [user objectForKey:@"picture"];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                       UIImage *image = [UIImage imageWithData:data];
                        cell.profileImage.image = image;
                    }
            }];
    }
    else {
        user = [self.actualUsers objectAtIndex:indexPath.row];
        cell.iconView = nil;
        cell.name.text = [user objectForKey:@"username"];
    
        PFFile *file = [user objectForKey:@"picture"];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                cell.profileImage.image = image;
            }
        }];
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.tentativeUsers count] > 0) {
        if(section == 0) {
            return @"Pending Users";
        }
        else return @"Group Users";
    }
    else {
        return @"Group Users";
    }
}

- (void) approveMember:(id)sender {
    
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        if (indexPath != nil) {
               [[ParseManager getInstance] addUser:[self.tentativeUsers objectAtIndex:indexPath.row] toGroup:_group];
            SendMemberApprovedPush(_group, [self.tentativeUsers objectAtIndex:indexPath.row]);
                self.selected = YES;
               [self.tableView reloadData];
            }
    }

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        //[tableView deselectRowAtIndexPath:indexPath animated:NO];
    }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        return 100;
    }

- (void) didloadNewUsers:(NSArray *)users WithError:(NSError *)error {
    [[Utility getInstance] hideProgressHud];
    SearchToAddUsers *searchVC = [SearchToAddUsers new];
    searchVC.candidateUsers = users;
    searchVC.group = self.group;
    [self.navigationController pushViewController:searchVC animated:YES];
}

@end