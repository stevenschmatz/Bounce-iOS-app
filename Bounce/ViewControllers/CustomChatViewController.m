//
//  ChatViewController.m
//  bounce
//
//  Created by Robin Mehta on 3/29/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "CustomChatViewController.h"
#import "Utility.h"
#import "ParseManager.h"
#import "Constants.h"
#import "UIView+AutoLayout.h"
#import "AppConstant.h"
#import "bounce-Swift.h"
#import "HomepointDropdownCell.h"

@interface CustomChatViewController ()
@property (nonatomic, strong) NSMutableArray *receivers;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic, weak) UIView *shadowView;
@property (nonatomic) CGPoint buttonPosition;
@end

@implementation CustomChatViewController
{
    UIAlertView *requestTimeOverAlert;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.receivers = [NSMutableArray new];
    
    self.homepointChat = NO;
    
    UILabel *navLabel = [UILabel new];
    navLabel.textColor = [UIColor whiteColor];
    navLabel.backgroundColor = [UIColor clearColor];
    navLabel.textAlignment = NSTextAlignmentCenter;
    navLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:20];
    self.navigationItem.titleView = navLabel;
    navLabel.text = @"Leaving Soon Nearby";
    [navLabel sizeToFit];
    
    [self.inputToolbar kgn_pinToBottomEdgeOfSuperviewWithOffset:44 + TAB_BAR_HEIGHT];
    
    self.navigationController.navigationBar.barTintColor = BounceRed;
    self.navigationController.navigationBar.translucent = NO;
    UIButton *customButton = [[Utility getInstance] createCustomButton:[UIImage imageNamed:@"common_back_button"]];
    [customButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
     self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customButton];
    
    UIButton *rightButton = [[Utility getInstance] createCustomButton:[UIImage imageNamed:@"whiteUser"]];
    [rightButton addTarget:self action:@selector(showDropDown) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
}

- (void) loadReceivers {
    if ([[Utility getInstance]checkReachabilityAndDisplayErrorMessage]) {
        MAKE_A_WEAKSELF;
        
        PFRelation *removedUsers = [self.currentRequest1 relationForKey:@"removedUsers"];
        PFQuery *removedUsersQuery = [removedUsers query];
        
        PFRelation *usersRelation = [self.currentRequest1 relationForKey:@"joinedUsers"];
        PFQuery *query = [usersRelation query];
        [query whereKey:OBJECT_ID doesNotMatchKey:OBJECT_ID inQuery:removedUsersQuery];
        [query setLimit:1000];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                weakSelf.receivers = [NSMutableArray arrayWithArray:objects];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                });
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.delegate setTabBarHidden:true];
    [self loadReceivers];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.delegate setTabBarHidden:false];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadMessages{
    // is Request still valid
    // retreive requet
    // validate request end
    // if request still valid
    //    self.currentRequest = [[ParseManager getInstance] retrieveRequest:self.currentRequest];
    
    [super loadMessages];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.currentRequest = [[ParseManager getInstance] retrieveRequestUpdate:self.groupId];
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL requestEnded = [[self.currentRequest objectForKey:PF_REQUEST_IS_ENDED] boolValue];
            if (self.currentRequest&& !requestEnded && [[Utility getInstance] isRequestValid:self.currentRequest.createdAt andTimeAllocated:[[self.currentRequest objectForKey:PF_REQUEST_TIME_ALLOCATED] integerValue]]) {
                if (![self isUserStillReceiverForTheRequest]) {
                    [self clearMessagesAndStopUpdate];
                    [self showAlertViewWithMessage:@"Oops! Looks like you're no longer within the request radius."];
                }
            }
            else {
                // delete all messages
                [self clearMessagesAndStopUpdate];
                [self showAlertViewWithMessage:@"Request time over"];
            }

        });
    });
}

#pragma mark - Alert view Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];

}
#pragma mark - Is user still in the request
- (BOOL) isUserStillReceiverForTheRequest
{
    return [[ParseManager getInstance] isValidRequestReceiver:self.currentRequest];

//    return  YES;
}

#pragma mark - Show Alert
- (void) showAlertViewWithMessage:(NSString *) message
{
    if (!requestTimeOverAlert) {
        requestTimeOverAlert = [[UIAlertView alloc] initWithTitle:@"Time to leave!" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [requestTimeOverAlert show];
    }
   }
#pragma mark - Clear Messages
- (void) clearMessagesAndStopUpdate
{
    @try {
        [self.messages removeAllObjects];
        [self.collectionView reloadData];
        [self.timer invalidate];
    }
    @catch (NSException *exception) {
    }
}

#pragma mark - back Button Action
-(void)backButtonClicked{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.receivers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellId = @"homepointCell";
    HomepointDropdownCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [HomepointDropdownCell new];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.contentView.backgroundColor = BounceLightGray;
    NSMutableArray *images = [NSMutableArray new];
    for (int i = 0; i < [self.receivers count]; i++) {
        PFFile *file = [self.receivers[i] valueForKey:@"picture"];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                if (indexPath.row == i) {
                    UIImage *image = [UIImage imageWithData:data];
                    [images addObject:image];
                    cell.hpImage.image = image;
                    cell.hpImage.contentMode = UIViewContentModeScaleToFill;
                    cell.hpImage.backgroundColor = [UIColor blackColor]; // this should never show
                }
            }
        }];
    }
    
    cell.homepointName.font = [UIFont fontWithName:@"AvenirNext-Regular" size:16];
    [cell.homepointName kgn_centerVerticallyInSuperview];
    cell.homepointName.text = [[self.receivers objectAtIndex:indexPath.row] valueForKey:PF_USER_FULLNAME];
    cell.homepointName.numberOfLines = 0;
    
    UIImage *img = [UIImage imageNamed:@"redX"];
    UIButton *iconView = [UIButton new];
    [cell.contentView addSubview:iconView];
    [iconView kgn_pinToRightEdgeOfSuperviewWithOffset:20];
    [iconView kgn_centerVerticallyInSuperview];
    [iconView setImage:img forState:UIControlStateNormal];
    
//    if (indexPath.row == self.index) {
//        UIImage *img = [UIImage imageNamed:@"confirmRequest"];
//        [cell.iconView setImage:img forState:UIControlStateNormal];
//    }
    
    [iconView addTarget:self action:@selector(removeUser:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void) removeUser:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Remove user from chat?"
                                                    message: @"Removing a user will disallow them from re-entering this chat. If this user isn't participating, it's a good idea to remove them, before sharing where you are."
                                                   delegate: self
                                          cancelButtonTitle: @"Cancel"
                                          otherButtonTitles: @"Continue", nil];
    [alert show];
    
    self.buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
}

#pragma mark - alertview delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:self.buttonPosition];
        if (indexPath != nil) {
            PFUser *user = [self.receivers objectAtIndex:indexPath.row];
                self.selectedIndex = indexPath.row;
                
                if ([[Utility getInstance]checkReachabilityAndDisplayErrorMessage]) {
                    
                    PFRelation *relation = [self.currentRequest1 relationForKey:@"removedUsers"];
                    [relation addObject:user];
                    [self.currentRequest1 saveInBackground];
                    [self.receivers removeObjectAtIndex:indexPath.row];
                    [self.tableView reloadData];
                }
            }
    }
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedIndex = indexPath.row;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

-(void)showDropDown {
    
    if (!_tableView) {
        UITableView *tableView = [UITableView new];
        tableView.backgroundColor = BounceLightGray;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.hidden = YES;
        tableView.separatorColor = BounceRed;
        [self.view addSubview:tableView];
        [tableView kgn_sizeToHeight:300];                             // TODO: ADJUST THIS
        [tableView kgn_sizeToWidth:self.view.frame.size.width - 80];
        [tableView kgn_pinToTopEdgeOfSuperviewWithOffset:3];
        [tableView kgn_pinToRightEdgeOfSuperviewWithOffset:5];
        self.tableView = tableView;
    }
    
    BOOL shouldHide = !self.tableView.hidden;
    
    if (self.tableView.hidden) {
        self.tableView.hidden = shouldHide;
        self.shadowView.hidden = shouldHide;
    }
    
    double originalOpacity = shouldHide ? 1.0 : 0.0;
    double newOpacity = shouldHide ? 0.0 : 1.0;
    
    self.tableView.layer.opacity = originalOpacity;
    self.shadowView.layer.opacity = originalOpacity;
    [UIView animateWithDuration:0.15f animations: ^void() {
        self.shadowView.layer.opacity = newOpacity;
        self.tableView.layer.opacity = newOpacity;
    } completion:^(BOOL finishedCompletion) {
        if (shouldHide) {
            self.shadowView.hidden = shouldHide;
            self.tableView.hidden = shouldHide;
        }
    }];
}


@end
