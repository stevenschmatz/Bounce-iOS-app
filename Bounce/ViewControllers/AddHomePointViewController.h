//
//  AddHomePointViewController.h
//  bounce
//
//  Created by Robin Mehta on 3/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseManager.h"

@interface AddHomePointViewController : UITableViewController <
    ParseManagerUpdateGroupDelegate,
    ParseManagerDelegate,
    ParseManagerLoadingGroupsDelegate,
    UIActionSheetDelegate,
    ParseManagerGetAllOtherGroups,
    UISearchResultsUpdating,
    UISearchControllerDelegate,
    ParseManagerGetFacebookFriendsDelegate
>

@property (strong, nonatomic) UICollectionView *collectionView;

@property NSMutableArray *homepointImages;

@property (nonatomic, strong) NSArray *allGroups;

@end
