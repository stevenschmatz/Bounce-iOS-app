//
//  HomepointDropdownCell.m
//  bounce
//
//  Created by Robin Mehta on 8/31/15.
//  Copyright (c) 2015 Bounce Labs, Inc. All rights reserved.
//

#import "HomepointDropdownCell.h"
#import "UIView+AutoLayout.h"

@implementation HomepointDropdownCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        UIImageView *hpImage = [UIImageView new];
        [self.contentView addSubview:hpImage];
        self.hpImage = hpImage;
        [hpImage kgn_sizeToHeight:56];
        [hpImage kgn_sizeToWidth:56];
        [hpImage kgn_pinToLeftEdgeOfSuperviewWithOffset:20];
        [hpImage kgn_centerVerticallyInSuperview];

        self.hpImage.layer.cornerRadius = 28;
        self.hpImage.clipsToBounds = true;
        
        UILabel *requestedGroups = [UILabel new];
        requestedGroups.textColor = [UIColor blackColor];
        requestedGroups.font = [UIFont fontWithName:@"AvenirNext-Regular" size:22];
        requestedGroups.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:requestedGroups];
        self.homepointName = requestedGroups;
        [requestedGroups kgn_pinToTopEdgeOfSuperviewWithOffset:16];
        [requestedGroups kgn_positionToTheRightOfItem:hpImage withOffset:22];
        
        UILabel *distanceLabel = [UILabel new];
        distanceLabel.textColor = [UIColor grayColor];
        distanceLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:12];
        distanceLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:distanceLabel];
        self.distanceLabel = distanceLabel;
        [distanceLabel kgn_positionBelowItem:requestedGroups];
        [distanceLabel kgn_pinLeftEdgeToLeftEdgeOfItem:requestedGroups];
        
        UILabel *nearbyUsers = [UILabel new];
        nearbyUsers.textColor = [UIColor grayColor];
        nearbyUsers.font = [UIFont fontWithName:@"AvenirNext-Regular" size:12];
        nearbyUsers.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:nearbyUsers];
        self.nearbyUsers = nearbyUsers;
        [nearbyUsers kgn_positionBelowItem:distanceLabel];
        [nearbyUsers kgn_pinLeftEdgeToLeftEdgeOfItem:distanceLabel];
    }
    return self;
}

@end
