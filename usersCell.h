//
//  usersCell.h
//  bounce
//
//  Created by Robin Mehta on 11/17/15.
//  Copyright © 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface usersCell : UITableViewCell

@property (nonatomic, weak) UILabel *name;
@property (nonatomic, weak) UILabel *addedBy;
@property (nonatomic, weak) UIImageView *profileImage;
@property (nonatomic, weak) UIButton *iconView;
@property (nonatomic, weak) UILabel *requestAdded;

@property (nonatomic, weak) UILabel *distance;
@property (nonatomic, weak) UILabel *address;
@property (nonatomic, weak) UILabel *friendsLabel;

@end
