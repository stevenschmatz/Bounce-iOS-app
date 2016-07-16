//
//  CreateHomepoint.h
//  bounce
//
//  Created by Robin Mehta on 7/14/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseManager.h"

@interface CreateHomepoint : UIViewController<ParseManagerUpdateGroupDelegate, ParseManagerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITextField *groupNameTextField;
@property (nonatomic, strong) UIButton *addLocationButton;
@property (nonatomic, strong) UIButton *addPhotoButton;
@property (nonatomic, strong) UIImageView *addImageIcon;
@property (nonatomic, strong) UIImageView *editImageIcon;
@property (nonatomic, strong) UIView *overlay;
@property (nonatomic, strong) UILabel *homepointHint;
@property (nonatomic, strong) UIAlertController *imageActionSheet;
@property (nonatomic) CGFloat buttonHeight;
@property (nonatomic) CGFloat buttonWidth;
@property (nonatomic) BOOL imageAdded;
@property (nonatomic) BOOL keyboardUp;

@end
