//
//  chatCell.m
//  bounce
//
//  Created by Robin Mehta on 7/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "chatCell.h"
#import "UIView+AutoLayout.h"

@implementation chatCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.backgroundColor = BounceRed;
        
        UIImageView *chatArrow = [UIImageView new];
        chatArrow.image = [UIImage imageNamed:@"chatArrow"];
        [self.contentView addSubview:chatArrow];
        [chatArrow kgn_pinToRightEdgeOfSuperviewWithOffset:15];
        [chatArrow kgn_centerVerticallyInSuperview];

        UIImageView *hpImage = [UIImageView new];
        [self.contentView addSubview:hpImage];
        self.hpImage = hpImage;
        [hpImage kgn_sizeToHeight:85];
        [hpImage kgn_sizeToWidth:85];
        [hpImage kgn_pinToLeftEdgeOfSuperviewWithOffset:15];
        [hpImage kgn_centerVerticallyInSuperview];

        self.hpImage.layer.borderWidth = 4.0f;
        self.hpImage.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.hpImage.layer.cornerRadius = 42.5f;
        self.hpImage.clipsToBounds = true;

        UILabel *requestedGroups = [UILabel new];
        requestedGroups.textColor = [UIColor whiteColor];
        requestedGroups.font = [UIFont fontWithName:@"AvenirNext-Regular" size:22];
        requestedGroups.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:requestedGroups];
        self.requestedGroups = requestedGroups;
        [requestedGroups kgn_pinTopEdgeToTopEdgeOfItem:self.hpImage withOffset:5];
        [requestedGroups kgn_positionToTheRightOfItem:hpImage withOffset:15];
        
        UILabel *genderType = [UILabel new];
        genderType.textColor = [UIColor colorWithWhite:1.0 alpha:0.69];
        genderType.font = [UIFont fontWithName:@"Avenir-Roman" size:16];
        [self.contentView addSubview:genderType];
        self.genderType = genderType;
        [genderType kgn_positionToTheRightOfItem:hpImage withOffset:15];
        [genderType kgn_positionBelowItem:requestedGroups withOffset:0];
        
        UILabel *timeLeft = [UILabel new];
        timeLeft.textColor = [UIColor colorWithWhite:1.0 alpha:0.69];
        timeLeft.font = [UIFont fontWithName:@"Avenir-Roman" size:16];
        [self.contentView addSubview:timeLeft];
        self.requestTimeLeft = timeLeft;
        [timeLeft kgn_positionToTheRightOfItem:hpImage withOffset:15];
        [timeLeft kgn_positionBelowItem:genderType withOffset:0];
        
        UILabel *peopleDescription = [UILabel new];
        peopleDescription.text = @"Loading";
        peopleDescription.numberOfLines = 0;
        peopleDescription.textColor = [UIColor colorWithWhite:1.0 alpha:0.69];
        peopleDescription.font = [UIFont fontWithName:@"Avenir-Roman" size:16];
        [self.contentView addSubview:peopleDescription];
        self.peopleDescription = peopleDescription;
        [peopleDescription kgn_positionToTheRightOfItem:hpImage withOffset:15];
        [peopleDescription kgn_positionBelowItem:timeLeft withOffset:0];
        
        self.layer.borderColor = [BounceRed CGColor];
        self.layer.borderWidth = 0.5f;
    }
    return self;
}


@end
