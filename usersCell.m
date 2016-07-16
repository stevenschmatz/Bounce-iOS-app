//
//  usersCell.m
//  bounce
//
//  Created by Robin Mehta on 11/17/15.
//  Copyright © 2015 hobble. All rights reserved.
//

#import "usersCell.h"
#import "UIView+AutoLayout.h"

@implementation usersCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UILabel *addedBy = [UILabel new];
        addedBy.translatesAutoresizingMaskIntoConstraints = NO;
        addedBy.textColor = [UIColor blackColor];
        addedBy.font = [UIFont fontWithName:@"Avenir-Light" size:28];
        [self.contentView addSubview:addedBy];
        [addedBy kgn_centerHorizontallyInSuperview];
        [addedBy kgn_centerVerticallyInSuperviewWithOffset:-40];
        self.addedBy = addedBy;
        
        UIImageView *profileImage = [UIImageView new];
        [self.contentView addSubview:profileImage];
        self.profileImage = profileImage;
        [profileImage kgn_sizeToHeight:80];
        [profileImage kgn_sizeToWidth:80];
        [profileImage kgn_pinToLeftEdgeOfSuperviewWithOffset:20];
        [profileImage kgn_centerVerticallyInSuperview];
        
        self.profileImage.layer.borderWidth = 6.0f;
        self.profileImage.layer.borderColor = [BounceSeaGreen CGColor];
        self.profileImage.layer.cornerRadius = 40.0f;
        self.profileImage.clipsToBounds = true;
        
        UILabel *name = [UILabel new];
        name.translatesAutoresizingMaskIntoConstraints = NO;
        name.textColor = [UIColor blackColor];
        name.font = [UIFont fontWithName:@"AvenirNext-Medium" size:18];
        [self.contentView addSubview:name];
        //[name kgn_pinToTopEdgeOfSuperviewWithOffset:20];
        [name kgn_positionToTheRightOfItem:profileImage withOffset:20];
        [name kgn_centerVerticallyInSuperview];
        self.name = name;
        
        UILabel *friendsLabel = [UILabel new];
        friendsLabel.translatesAutoresizingMaskIntoConstraints = false;
        friendsLabel.numberOfLines = 0;
        friendsLabel.textColor = [UIColor colorWithWhite:0.0 alpha:0.8];
        friendsLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:12];
        [self.contentView addSubview:friendsLabel];
        [friendsLabel kgn_positionBelowItem:name withOffset:6];
        [friendsLabel kgn_positionToTheRightOfItem:profileImage withOffset:20];
        [friendsLabel kgn_sizeToWidth:self.contentView.frame.size.width - 150];
        self.friendsLabel = friendsLabel;
        
        UILabel *address = [UILabel new];
        address.translatesAutoresizingMaskIntoConstraints = NO;
        address.numberOfLines = 0;
        address.textColor = [UIColor colorWithWhite:0.0 alpha:0.7];
        address.font = [UIFont fontWithName:@"AvenirNext-Medium" size:12];
        [self.contentView addSubview:address];
        [address kgn_positionBelowItem:friendsLabel withOffset:4];
        [address kgn_positionToTheRightOfItem:profileImage withOffset:20];
        [address kgn_sizeToWidth:self.contentView.frame.size.width - 150];
        self.address = address;
        
        UIButton *iconView = [UIButton new];
        [self.contentView addSubview:iconView];
        self.iconView = iconView;
        [iconView kgn_pinToRightEdgeOfSuperviewWithOffset:20];
        [iconView kgn_centerVerticallyInSuperview];
        
        UILabel *requestSent = [UILabel new];
        requestSent.translatesAutoresizingMaskIntoConstraints = NO;
        requestSent.textColor = [UIColor blackColor];
        requestSent.font = [UIFont fontWithName:@"Avenir-Light" size:12];
        requestSent.text = nil;
        [self.contentView addSubview:requestSent];
        [requestSent kgn_centerVerticallyInSuperview];
        [requestSent kgn_pinToRightEdgeOfSuperviewWithOffset:20];
        self.requestAdded = requestSent;
    }
    return self;
}

@end
