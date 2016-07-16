//
//  HomePointGroupsViewController.h
//  bounce
//
//  Created by Robin Mehta on 3/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ParseManager.h"

@interface AddGroupUsersViewController : UITableViewController <ParseManagerAddGroupDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property NSArray *candidateUsers;
@property (nonatomic, assign) PFGeoPoint * groupLocation;
@property (strong, nonatomic) NSString* groupName;
@property PFObject *updatedGroup;
@property (nonatomic, strong) NSMutableArray *selectedUsers;
@property (nonatomic, strong) UIImage *homepointImage;

@property (strong, nonatomic) NSString *address;

@end
