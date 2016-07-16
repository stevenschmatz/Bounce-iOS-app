//
//  addUsersCell.h
//  bounce
//
//  Created by Robin Mehta on 8/13/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseManager.h"

@interface membersCell : UITableViewCell <ParseManagerGetTentativeUsers>


@property (nonatomic, weak) UILabel *name;
@property (nonatomic, weak) UILabel *addedBy;
@property (nonatomic, weak) UIImageView *profileImage;
@property (nonatomic, weak) UIButton *iconView;
@property (nonatomic, weak) UILabel *requestAdded;

@property (nonatomic, weak) UILabel *distance;
@property (nonatomic, weak) UILabel *address;
@property (nonatomic, weak) UILabel *friendsLabel;
@property (nonatomic, strong) PFObject *group;


@end