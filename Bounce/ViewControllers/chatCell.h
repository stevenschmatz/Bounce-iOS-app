//
//  chatCell.h
//  bounce
//
//  Created by Robin Mehta on 7/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface chatCell : UITableViewCell

@property (nonatomic, weak) UILabel *numMessages;
@property (nonatomic, weak) UILabel *timeCreated;
@property (nonatomic, weak) UILabel *chatTitle;
@property (nonatomic, weak) UILabel *genderType;
@property (nonatomic, weak) UILabel *requestTimeLeft;
@property (nonatomic, weak) UILabel *lastMessage;
@property (nonatomic, weak) UILabel *requestedGroups;
@property (nonatomic, weak) UIImageView *hpImage;
@property (nonatomic, weak) UILabel *peopleDescription;

@end
