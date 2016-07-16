//
//  RequestManger.m
//  ChattingApp
//
//  Created by Robin Mehta on 3/29/15.
//  Copyright (c) 2015 Bounce Labs, Inc. All rights reserved.
//

#import "RequestManger.h"
#import <Parse/Parse.h>
#import "AppConstant.h"
#import "ParseManager.h"
#import "Constants.h"
#import "Utility.h"

@implementation RequestManger
{
    PFObject *activeRequest;
    NSTimer *startRequestTimer;
    BOOL isUpdating;
    
}
static RequestManger *sharedRequestManger = nil;

+ (RequestManger*) getInstance{
    @try {
        @synchronized(self)
        {
            if (sharedRequestManger == nil)
            {
                sharedRequestManger = [[RequestManger alloc] init];
            }
        }
        return sharedRequestManger;
    }
    @catch (NSException *exception) {
    }
}

#pragma mark - Request
- (void) createrequestToGroups:(NSArray *) selectedGroups andGender:(NSString *)gender  withinTime:(NSInteger)timeAllocated andInRadius:(NSInteger) radius{
    @try {
        PFUser *currentUser = [PFUser currentUser];
        if (![gender isEqualToString:ALL_GENDER]) {
            gender = [currentUser objectForKey:PF_GENDER];
        }
        if (!gender) {
            gender = ALL_GENDER;
        }
        PFGeoPoint *userGeoPoint = currentUser[PF_USER_LOCATION];
        
        if (userGeoPoint != nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            // get User in the selected groups and within the radius
            NSArray *resultUsers = [self getUsersInSelectedGroups:selectedGroups withGender:gender WithinRequestRadius:radius withSenderName:[currentUser username] andSenderLocation:userGeoPoint];
            
            // Get User names
            NSMutableArray *resultUsernames = [[NSMutableArray alloc] init];
            for (PFUser *user in resultUsers) {
                NSLog(@"%@", user.username);
                [resultUsernames addObject:user.username];
            }
            
            // Set the request data
            PFObject *request;
            request = [PFObject objectWithClassName:PF_REQUEST_CLASS_NAME];
            request[PF_REQUEST_SENDER] = [PFUser currentUser];
            request[PF_REQUEST_RECEIVER] = resultUsernames;
            request[PF_REQUEST_RADIUS] = [NSNumber numberWithInteger:radius];
            request[PF_REQUEST_TIME_ALLOCATED] = [NSNumber numberWithInteger:timeAllocated + 15]; // Buffer of 15 minutes
            request[PF_REQUEST_LOCATION] = [[PFUser currentUser] objectForKey:PF_USER_LOCATION];
            request[PF_GENDER] = gender;
            
            [[request relationForKey:@"joinedUsers"] addObject:[PFUser currentUser]];
            
            NSMutableArray *groupNames = [NSMutableArray new];
            
            for (int i = 0; i < [selectedGroups count]; i++) {
                [groupNames addObject:[[selectedGroups objectAtIndex:i] objectForKey:PF_GROUPS_NAME]];
            }
            
            request[PF_REQUEST_HOMEPOINTS] = groupNames;

            [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                request[PF_REQUEST_END_DATE] = [[request createdAt] dateByAddingTimeInterval:(timeAllocated*60)];
                
                [self setRequestGroupRelation:request withGroups:selectedGroups];
                [self appendUsers:resultUsers toRequestUserRelation:request];

                [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {

                        NSString *requestId = request.objectId;
                        [[ParseManager getInstance] createMessageItemForUser:currentUser WithGroupId:requestId andDescription:@"request"];
                        [self createChatItemAndSendNotificationToUsers:resultUsers withRequestId:requestId];
                        activeRequest = request;

                        self.requestLeftTimeInMinute = timeAllocated;
                        [self startRequestUpdating];
                    }
                    if ([self.createRequestDelegate respondsToSelector:@selector(didCreateRequestWithError:)]) {
                        [self.createRequestDelegate didCreateRequestWithError:error];
                    }
                }];
            }];
        });
    }
    else {
        [[Utility getInstance] hideProgressHud];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Where are you?"
                                                        message: @"Please go to Settings > Bounce > Location, and allow us to use your location!"
                                                       delegate: self
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - Get Users in selected groups within radius
- (NSArray*) getUsersInSelectedGroups:(NSArray *)selectedGroups withGender:(NSString*) gender WithinRequestRadius:(NSInteger)radius withSenderName:(NSString *)username andSenderLocation:(PFGeoPoint*) location
{
    @try {
        PFQuery *query = [PFUser query];
        NSMutableArray *queries = [[NSMutableArray alloc] init];
        
        // go through all groups to find users who are near
        for (PFObject *group in selectedGroups) {
            PFRelation *usersIngroup = [group relationForKey:PF_GROUP_Users_RELATION];
            PFQuery *query = [usersIngroup query];
            [query whereKey:PF_USER_USERNAME notEqualTo:username];
            if (![gender isEqualToString:ALL_GENDER]) {
                [query whereKey:PF_GENDER equalTo:gender];
            }
            [query whereKey:PF_USER_LOCATION nearGeoPoint:location withinMiles:K_NEAR_DISTANCE];
            [queries addObject:query];
        }
        query = [PFQuery orQueryWithSubqueries:queries];
        NSArray *resultUsers = [query findObjects];
        return resultUsers;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - Add Object to request user relation
// Append the new users to the request user relation
// With out saving, Saving will be in the called function
- (void) appendUsers:(NSArray *) users toRequestUserRelation:(PFObject *) request
{
    @try {
        PFRelation *receiversRelation = [request relationForKey:PF_REQUEST_RECEIVERS_RELATION];
        for (PFObject *user in users) {
            [receiversRelation addObject:user];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - Set the request group relation
- (void) setRequestGroupRelation:(PFObject *) request withGroups:(NSArray *) selectedGroups
{
    @try {
        PFRelation *groupsrelation = [request relationForKey:PF_REQUEST_GROUPS_RELATION];
        for (PFObject *group in selectedGroups) {
            [groupsrelation addObject:group];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - Create Chat Item and Send push notification
- (void) createChatItemAndSendNotificationToUsers:(NSArray *) users withRequestId:(NSString *) requestId
{
    @try {
        PFUser *currentUser = [PFUser currentUser];
        for (PFUser* user in users) {
            
            // Create chat item
            [[ParseManager getInstance] createMessageItemForUser:user WithGroupId:requestId andDescription:@""];
            
            // Notify the user with the request
            [self sendPushNotificationForUser:user from:[currentUser username] WithRequestId:requestId];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - Add chat to request receiver
- (void) sendPushNotificationForUser:(PFUser *) user from:(NSString *) senderName WithRequestId:(NSString *) requestId
{
    @try {
        PFQuery *queryInstallation = [PFInstallation query];
        [queryInstallation whereKey:PF_INSTALLATION_USER equalTo:user];
        
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:queryInstallation];

        NSString *alertMessage = [NSString stringWithFormat:@"Heading home soon? %@ created a leaving group nearby!", senderName];
        NSDictionary *data = [[NSDictionary alloc] initWithObjects:@[requestId, alertMessage] forKeys:@[OBJECT_ID, NOTIFICATION_ALERT_MESSAGE]];
        [push setData:data];
        [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil)
             {
                 NSLog(@"SendPushNotification send error.");
             }
         }];
    }
    @catch (NSException *exception) {
    }
}


#pragma mark - Start Request update
- (void) startRequestUpdating
{
    if (!startRequestTimer) {
        startRequestTimer = [NSTimer scheduledTimerWithTimeInterval:REQUEST_UPDATE_REPEATINTERVAL target:self selector:@selector(updatRequest) userInfo:nil repeats:YES];
    }
}

#pragma mark - Update Request
/*
 // if request time over == >invalidate request
 // else get new users whic near from me
 // remove the far users
*/
- (void) updatRequest
{
    @try {
        NSDate *endDate = [[activeRequest createdAt] dateByAddingTimeInterval:[[activeRequest objectForKey:PF_REQUEST_TIME_ALLOCATED] integerValue] * 60];
        
        if (![self isEndDateIsSmallerThanCurrent:endDate]) {
            
            // Update Request view in home screen
            [self calculateRequestTimeOver];
            [self getNumberOfUnReadMessages];
            
            // check if update is already runing
            if (!isUpdating) {
                isUpdating = YES;
                //Update request
                [self updateRequestUsers];
            }
        } else {
            // invalidate the request
            [self requestBecomeInvalid];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - Request time over
- (void) requestBecomeInvalid
{
    // delete request data
    // update the reply view in home screen
    [[ParseManager getInstance] deleteAllRequestData:activeRequest];
    [self invalidateCurrentRequest];
    activeRequest = nil;
    if ([self.requestManagerDelegate respondsToSelector:@selector(requestTimeOver)]) {
        [self.requestManagerDelegate requestTimeOver];
    }
}

#pragma mark - Update Request Users
- (void) updateRequestUsers
{
    @try {
        PFUser *currentUser = [PFUser currentUser];
        PFGeoPoint *userGeoPoint = currentUser[@"CurrentLocation"];
        NSInteger radius = K_NEAR_DISTANCE; // [[activeRequest objectForKey:PF_REQUEST_RADIUS] integerValue]
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *selectedGroups = [self getRequestSelectedGroups];
            NSMutableArray *oldUsers = [[NSMutableArray alloc] initWithArray:[self getRequestReceivers]];
            // get User in the selected groups and within the radius
            NSArray *resultUsers = [self getUsersInSelectedGroups:selectedGroups withGender:[activeRequest objectForKey:PF_GENDER] WithinRequestRadius:radius withSenderName:[currentUser username] andSenderLocation:userGeoPoint];
            // Filter added and removed users
            NSMutableArray *resultUsernames = [[NSMutableArray alloc] init];
            NSMutableArray *addedUsers = [[NSMutableArray alloc] init];
            NSMutableArray *removedUsers = [[NSMutableArray alloc] init];
            for (PFUser *user in resultUsers) {
                [resultUsernames addObject:user.username];
                NSLog(@"%@", user.username);
                if (![oldUsers containsObject:user]) {
                    [addedUsers addObject:user];
                }else{
                    // remove this user from list
                    [oldUsers removeObject:user];
                }
            }
            // After finish the remaining users in the oldUserNames ==> are the removed users
            removedUsers = [NSMutableArray arrayWithArray:oldUsers];
            if ([addedUsers count] != 0 || [removedUsers count] > 0) {
                // update request record
                activeRequest[PF_REQUEST_RECEIVER] = resultUsernames;
                [self appendUsers:addedUsers toRequestUserRelation:activeRequest];
                [self removeUsers:removedUsers fromRequestUserRelation:activeRequest];
                BOOL saveSucceeded = [activeRequest save];
                if (saveSucceeded) {
                    NSString *requestId = activeRequest.objectId;
                    // update request user relation
                    // send push notification for new users and create chat item
                    [self createChatItemAndSendNotificationToUsers:addedUsers withRequestId:requestId];
                    [self removeRequestDataForRemovedUser:removedUsers];
                }
            } else {
            }
            isUpdating = NO;
        });
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - Remove User from request user relation
- (void) removeUsers:(NSArray *) users fromRequestUserRelation:(PFObject *) request
{
    @try {
        PFRelation *receiversRelation = [request relationForKey:PF_REQUEST_RECEIVERS_RELATION];
        for (PFObject *user in users) {
            [receiversRelation removeObject:user];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - remove message chat of delete users
- (void) removeRequestDataForRemovedUser:(NSArray *)removedUsers
{
    // remove related chatting data
    for (PFUser* user in removedUsers) {
        // remove chat item and chat messages if found
        [[ParseManager getInstance] deleteChatDataRelatedToRequestId:[activeRequest objectId] ForExactUser:user];
    }
}
#pragma mark - Get Selected Groups In Request
- (NSArray *) getRequestSelectedGroups
{
    @try {
        PFRelation *groupsRelation = [activeRequest relationForKey:PF_REQUEST_GROUPS_RELATION];
        PFQuery *query = [groupsRelation query];
        return [query findObjects];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}
#pragma mark - Get Receiver users In Request
- (NSArray *) getRequestReceivers
{
    @try {
        PFRelation *receiversRelation = [activeRequest relationForKey:PF_REQUEST_RECEIVERS_RELATION];
        PFQuery *query = [receiversRelation query];
        return [query findObjects];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - Compare dates
- (BOOL)isEndDateIsSmallerThanCurrent:(NSDate *)checkEndDate
{
    NSDate* enddate = checkEndDate;
    NSDate* currentdate = [NSDate date];
    NSTimeInterval distanceBetweenDates = [enddate timeIntervalSinceDate:currentdate];
    
    if (distanceBetweenDates == 0)
        return YES;
    else if (distanceBetweenDates < 0)
        return YES;
    else
        return NO;
}

#pragma mark - Invalidate Request
- (void) invalidateCurrentRequest
{
    if (startRequestTimer) {
        [startRequestTimer invalidate];
        startRequestTimer = nil;
    }
    activeRequest = nil;
}

#pragma mark - End Request
- (void) endRequest
{
    // Instead marked the request as deleted we become delete request data once it end
    [[ParseManager getInstance] deleteAllRequestData:activeRequest];
    [self invalidateCurrentRequest];
    if ([self.requestManagerDelegate respondsToSelector:@selector(didEndRequestWithError:)]) {
        [self.requestManagerDelegate didEndRequestWithError:nil];
    }
}

#pragma mark - Get Number of Unreaded messages
- (void) getNumberOfUnReadMessages
{
    @try {
        if ([PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];
        [query whereKey:PF_MESSAGES_USER equalTo:[PFUser currentUser]];
        [query whereKey:PF_MESSAGES_GROUPID equalTo:[activeRequest objectId]];

        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if ([objects count] >= 1) {
                 NSInteger unReadMessages = [[objects objectAtIndex:0][PF_MESSAGES_COUNTER] intValue];
                 self.unReadReplies = unReadMessages;
             if ([self.requestManagerDelegate respondsToSelector:@selector(updateRequestUnreadMessage:)]) {
                 [self.requestManagerDelegate updateRequestUnreadMessage:unReadMessages];
             }
             }
         }];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

- (void) calculateRequestTimeOver
{
    @try {
        self.requestLeftTimeInMinute = [[activeRequest objectForKey:PF_REQUEST_TIME_ALLOCATED] integerValue] - ([[NSDate date] timeIntervalSinceDate:[activeRequest createdAt]]/60) ;
        if ([self.requestManagerDelegate respondsToSelector:@selector(updateRequestRemainingTime:)]) {
            [self.requestManagerDelegate updateRequestRemainingTime:self.requestLeftTimeInMinute];
        }
    }
    @catch (NSException *exception) {
        
    }
}

- (BOOL) hasActiveRequest
{
    if (activeRequest) {
        return YES;
    }
    return NO;
}

/**
 * Saves the active request ID.
 */
- (void) loadActiveRequest
{
    // retreive request data from server
    PFQuery *query = [PFQuery queryWithClassName:PF_REQUEST_CLASS_NAME];
    [query whereKey:PF_REQUEST_SENDER equalTo:[PFUser currentUser]];
    [query orderByDescending:PF_CREATED_AT];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        // set the default data
        if ([objects count] > 0) {
            activeRequest = [objects objectAtIndex:0];

            if (![self isEndDateIsSmallerThanCurrent:[activeRequest objectForKey:PF_REQUEST_END_DATE]]) {
                // remaining time
                [self calculateRequestTimeOver];

                // unreaded message
                [self getNumberOfUnReadMessages];
                [self startRequestUpdating];
            } else {
                activeRequest = nil;
                self.unReadReplies = 0;
                self.requestLeftTimeInMinute = 0;

                //remove this request with it's chat data
                [[ParseManager getInstance] deleteAllRequestData:[objects objectAtIndex:0]];
            }
        }
    }];
}
@end
