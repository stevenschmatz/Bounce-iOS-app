//
//  homepointList.m
//  bounce
//
//  Created by Robin Mehta on 7/14/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "homepointListCell.h"
#import "UIView+AutoLayout.h"

@implementation homepointListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIImageView *cellBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
        UIView *overlay = [UIView new];
        [overlay setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
        [cellBackground addSubview:overlay];
        [overlay kgn_sizeToWidthAndHeightOfItem:cellBackground];
        self.backgroundView = cellBackground;
        self.cellBackground = cellBackground;
        
        UILabel *homepointName = [UILabel new];
        homepointName.translatesAutoresizingMaskIntoConstraints = NO;
        homepointName.textColor = [UIColor whiteColor];
        homepointName.font = [UIFont fontWithName:@"Avenir-Light" size:28]; // fix this value
        [self.contentView addSubview:homepointName];
        [homepointName kgn_centerHorizontallyInSuperview];
        [homepointName kgn_centerVerticallyInSuperviewWithOffset:-40];
        self.homepointName = homepointName;
        
        UILabel *usersNearby = [UILabel new];
        usersNearby.translatesAutoresizingMaskIntoConstraints = NO;
        usersNearby.textColor = [UIColor whiteColor];
        usersNearby.font = [UIFont fontWithName:@"Avenir-Light" size:14];
        [self.contentView addSubview:usersNearby];
        [usersNearby kgn_pinToBottomEdgeOfSuperviewWithOffset:10];
        [usersNearby kgn_pinToLeftEdgeOfSuperviewWithOffset:10];
        self.usersNearby = usersNearby;
        
        UILabel *distanceAway = [UILabel new];
        distanceAway.translatesAutoresizingMaskIntoConstraints = NO;
        distanceAway.textColor = [UIColor whiteColor];
        distanceAway.font = [UIFont fontWithName:@"Avenir-Light" size:14];
        [self.contentView addSubview:distanceAway];
        [distanceAway kgn_centerHorizontallyInSuperview];
        [distanceAway kgn_centerVerticallyInSuperviewWithOffset:15];
        self.distanceAway = distanceAway;
    }
    return self;
}

@end
