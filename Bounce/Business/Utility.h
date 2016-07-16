//
//  Utility.h
//  ChattingApp
//
//  Created by Robin Mehta on 3/16/15.
//  Copyright (c) 2015 Bounce Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProgressHUD.h"
#import "Reachability.h"
#import "CustomChatViewController.h"

@interface Utility : NSObject <UIAlertViewDelegate>

+ (Utility*) getInstance;

- (void) showProgressHudWithMessage:(NSString*)message withView:(UIView *)view;
- (void) showProgressHudWithMessage:(NSString*)message;
- (void) hideProgressHud;

// Network Connection
- (BOOL) checkReachabilityAndDisplayErrorMessage;
- (void)showAlertMessage:(NSString *)message;
-(void) showAlertWithMessage:(NSString*) message andTitle:(NSString*)title;
//
- (BOOL)isRequestValid:(NSDate *)craetedDate andTimeAllocated:(NSInteger) time;
- (BOOL)isRequestValidWithEndDate:(NSDate *)endDate;

-(UIButton *)createCustomButton:(UIImage*) buttonImage;

- (void) addRoundedBorderToView:(UIView *) view;
- (CustomChatViewController *) createChatViewWithRequestId:(NSString *) requestId;

@end
