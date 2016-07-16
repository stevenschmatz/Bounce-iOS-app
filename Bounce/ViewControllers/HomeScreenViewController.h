//
//  HomeScreenViewController.h
//  bounce
//
//  Created by Robin Mehta on 3/26/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>
#import "RequestManger.h"
#import <Parse/Parse.h>
#import "utilities.h"
#import "RequestsViewController.h"
#import "AppConstant.h"
#import "GroupsListViewController.h"
#import "RequestManger.h"
#import "UIView+AutoLayout.h"

@interface HomeScreenViewController : UIViewController <CLLocationManagerDelegate, UIGestureRecognizerDelegate, ParseManagerGetUserGroups, RequestManagerCreateRequestDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, ParseManagerGetNearUsersDelegate, MKMapViewDelegate>

@property (strong, nonatomic) id delegate;

@end
