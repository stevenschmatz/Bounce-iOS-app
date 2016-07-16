//
//  homepointList.h
//  bounce
//
//  Created by Robin Mehta on 7/14/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface homepointListCell : UITableViewCell

@property (nonatomic, weak) UIImageView *cellBackground;
@property (nonatomic, weak) UIImage *cellImage;
@property (nonatomic, weak) UILabel *homepointName;
@property (nonatomic, weak) UILabel *usersNearby;
@property (nonatomic, weak) UILabel *distanceAway;

@end
