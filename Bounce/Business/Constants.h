//
//  Constants.h
//  bounce
//
//  Created by Robin Mehta on 3/26/15.
//  Copyright (c) 2015 Bounce Labs, Inc. All rights reserved.
//

#ifndef bounce_Constants_h
#define bounce_Constants_h

#define MAKE_A_WEAKSELF     __weak typeof(self) weakSelf = self
#define MAKE_A_STRONGSELF   __strong typeof(weakSelf) strongSelf = weakSelf

#pragma mark - General Constants
#define IS_IOS8 ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)

#define IS_IPHONE ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)

#define IS_IPHONE4 ([[UIScreen mainScreen] bounds].size.height == 480)
#define IS_IPHONE5 ([[UIScreen mainScreen] bounds].size.height == 568)
#define IS_IPHONE6 ([[UIScreen mainScreen] bounds].size.height == 667)
#define IS_IPHONE6PLUS ([[UIScreen mainScreen] bounds].size.height == 736)
#define IS_IPAD ([[UIScreen mainScreen] bounds].size.height > 736)
// Colors
#define BounceRed       [UIColor colorWithRed:255/255.0 green:127/255.0 blue:124/255.0 alpha:1.0] // #FF7F7C
#define BounceGreen     [UIColor colorWithRed:202/255.0 green: 231/255.0 blue:185/255.0 alpha:1.0] // #CAE789
#define BounceYellow    [UIColor colorWithRed:234/255.0 green: 222/255.0 blue:138/255.0 alpha:1.0] //#F3DE8A
#define BounceBlue      [UIColor colorWithRed:115/255.0 green:127/255.0 blue:154/255.0 alpha:1.0] //#7E7F9A
#define BounceGrey      [UIColor colorWithRed:151/255.0 green:167/255.0 blue:179/255.0 alpha:1.0] //#97A7B3
#define BounceSeaGreen  [UIColor colorWithRed:0.314 green:0.89 blue:0.761 alpha:1.0]
#define BounceLightGray [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:1] /*#f5f5f5*/
#define BounceMadang    [UIColor colorWithRed:0.784 green:0.969 blue:0.773 alpha:1] /*#c8f7c5*/
#define BounceAliceBlue [UIColor colorWithRed:0.894 green:0.945 blue:0.996 alpha:1] /*#e4f1fe*/

#define LIGHT_BLUE_COLOR    [UIColor colorWithRed:120.0/250.0 green:175.0/250.0 blue:212.0/250.0 alpha:1.0]
#define LIGHT_SELECT_GRAY_COLOR    [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0f]

// Parse Request class
#define PF_REQUEST_CLASS_NAME @"Requests"
#define PF_REQUEST_TIME_ALLOCATED @"TimeAllocated"
#define PF_REQUEST_TIME @"TimeAllocated"
#define PF_REQUEST_RADIUS @"Radius"
#define PF_REQUEST_RECEIVER @"receivers"
#define PF_REQUEST_SENDER @"Sender"
#define PF_REQUEST_GROUPS_RELATION @"RequestGroups"
#define PF_REQUEST_RECEIVERS_RELATION @"RequestReceivers"
#define PF_REQUEST_LOCATION @"Location"
#define PF_REQUEST_IS_ENDED @"isEnded"

// save end date instead save the time allocate
#define PF_REQUEST_END_DATE @"EndDate"
#define PF_REQUEST_GENDER @"gender"
#define PF_REQUEST_HOMEPOINTS @"homepoints"
#define PF_REQUEST_LAST_MESSAGE @"LAST_MESSAGE"

#define DISTANCE_MESSAGE_IN_MILES @"%.1f miles away"
#define DISTANCE_MESSAGE_IN_FEET @"%d ft away"

#define SIDE_MENU_WIDTH (IS_IPHONE? 225:375)

#define OBJECT_ID @"objectId"
#define PF_GENDER @"Gender"
#define PF_CREATED_AT @"createdAt"

// Home screen
#define REQUEST_TIME_LEFT_STRING @"%i min left"
#define REQUEST_TIME_REMAINING_STRING @"%li min remaining"

// Gender cases
#define ALL_GENDER @"All"
#define MALE_GENDER @"male"
#define FEMALE_GENDER @"female"

#define COMMON_CORNER_WIDTH 3.0
// custom annotaion pin view
#define CUSTOM_ANNOTAION_OVERLAY_COLOR [[UIColor alloc] initWithRed:180/255.0 green:225./255.0 blue:232/255.0 alpha:.5]
#define INNER_VIEW_RADIUS 50
#define OUTER_VIEW_RADIUS 120
#define INNER_VIEW_ICON_RADIUS 50

#define LEAVING_GROUP_NOTIFICATION_PREFIX @"M"
#define HOMEPOINT_NOTIFICATION_PREFIX @"H"
#define PENDING_USER_NOTIFICATION_PREFIX @"N"
#define APPROVED_NOTIFICATION_PREFIX @"W"

//
#define FEET_IN_KILOMETER 3281

// Update chat number notification
#define CHAT @"Chat"
#define REQUEST_NUMBER_POST_NOTIFICATION @"UpdateChatNumber"

// near distance that user when get the distance to homepoint
// It is in miles
#define K_NEAR_DISTANCE 0.2

// request Updating interval time
#define REQUEST_UPDATE_REPEATINTERVAL 10


// Hud Messages
#define COMMON_HUD_SEND_MESSAGE @"Sending..."
#define COMMON_HUD_LOADING_MESSAGE @"Loading..."

// Alert Messages
#define FAILURE_SEND_MESSAGE @"Error! Please try to send the request again!"

// Notification
#define NOTIFICATION_ALERT_MESSAGE @"alert"

#endif
