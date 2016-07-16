//
//  ParseManager.h
//  ChattingApp
//
//  Created by Robin Mehta on 3/16/15.
//  Copyright (c) 2015 Bounce Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@protocol ParseManagerLoginDelegate;
@protocol ParseManagerSignupDelegate;
@protocol ParseManagerLoadingGroupsDelegate;
@protocol ParseManagerAddGroupDelegate;
@protocol ParseManagerGetUserGroups;
@protocol ParseManagerUpdateGroupDelegate;
@protocol ParseManagerFailureDelegate;
@protocol ParseManagerDelegate;
@protocol ParseManagerDeleteDelegate;
@protocol ParseManagerLoadNewUsers;
@protocol ParseManagerGetTentativeUsers;
@protocol ParseManagerGetAllOtherGroups;
@protocol ParseManagerGetFacebookFriendsDelegate;
@protocol ParseManagerGetNearUsersDelegate;

@interface ParseManager : NSObject

@property id<ParseManagerLoginDelegate> loginDelegate;
@property id<ParseManagerSignupDelegate> signupDelegate;
@property id<ParseManagerLoadingGroupsDelegate> loadGroupsdelegate;
@property id<ParseManagerAddGroupDelegate> addGroupdelegate;
@property id<ParseManagerGetUserGroups> getUserGroupsdelegate;
@property id<ParseManagerUpdateGroupDelegate> updateGroupDelegate;
@property id<ParseManagerFailureDelegate> failureDelegaet;
@property id<ParseManagerDelegate> delegate;
@property id<ParseManagerDeleteDelegate> deleteDelegate;
@property id<ParseManagerLoadNewUsers> loadNewUsers;
@property id<ParseManagerGetTentativeUsers> getTentativeUsersDelegate;
@property id<ParseManagerGetAllOtherGroups> getAllOtherGroupsDelegate;
@property id<ParseManagerGetFacebookFriendsDelegate> getFacebookFriendsDelegate;
@property id<ParseManagerGetNearUsersDelegate> getNearUsersDelegate;

+ (ParseManager*) getInstance;
// Chat message
- (void) createMessageItemForUser:(PFUser *)user WithGroupId:(NSString *) groupId andDescription:(NSString *)description;
// Groups
- (NSArray *) getAllGroupsExceptCreatedByUser;
- (void) isGroupNameExist:(NSString *) name;
- (void) addGroup:(NSString*) groupName withLocation:(PFGeoPoint*) location withImage:(UIImage *)image;
- (void) loadAllGroups;
- (void) addGroup:(NSString*) groupName withArrayOfUser:(NSArray *)users withLocation:(PFGeoPoint*) location withImage:(UIImage *)image withAddress:(NSString *)address;
// get request uodates
- (PFObject *) retrieveRequestUpdate:(NSString *) requstId;
// valid receiver
- (BOOL) isValidRequestReceiver:(PFObject*) request;
// nearUsers in group

// COMMENTED OUT TO SILENCE WARNING
//- (NSInteger) getNearUsersInGroup:(PFObject *) group;
// distance between user and group

- (double) getDistanceToGroup:(PFObject *) group;
// Get User groups
- (void) getUserGroups;
// Get Groups which currnt user not member at it
- (void) getCandidateGroupsForCurrentUser;
// remove group
- (void) removeGroup:(PFObject *) group;
- (void) deleteGroup:(PFObject *) group;
// Useres Operations
- (void) getAllUsers;
// check if there is a user logged in
- (BOOL) isThereLoggedUser;
// GET VALID REQUEST NUMBER
- (NSUInteger) getNumberOfValidRequests;
// Get user requests
- (void) getUserRequests;
// Delete Request
-(void) deleteRequest:(PFObject *) request;
- (void) deleteUser:(PFUser *) user FromRequest:(PFObject *) request;
- (void) deleteAllRequestData:(PFObject *) request;
- (void) deleteChatDataRelatedToRequestId:(NSString *) requestId ForExactUser:(PFUser *) user;
// Users in group
- (void) getCandidateUsersForGroup:(PFObject *) group;
- (void) getGroupUsers:(PFObject *) group;
- (void) addListOfUsers:(NSArray *) users toGroup:(PFObject *) group andRemove:(NSArray *) removedUsers;
- (void) addCurrentUserToGroup:(PFObject *) group;
- (void) removeUserFromGroup:(PFObject *) group;
- (void) addListOfUsers:(NSArray *) users toGroup:(PFObject *) group;
- (void) getTentativeUsersFromGroup:(PFObject *)group;
-(void)addUser:(PFUser *)user toGroup:(PFObject *)group;
- (void) getAllOtherGroupsForCurrentUser;
- (void)removeUser:(PFUser *)user fromTentativeGroup:(PFObject *)group;

- (void) addTentativeUserToGroup:(PFObject *)group withExistingTentativeUsers:(NSArray *)tentativeUsers;

- (NSUInteger)returnNumberOfValidRequestsWithNavigationController:(UINavigationController *)navigationController;

- (void) getFacebookFriends;

- (void) getNearUsersNumberInGroup:(PFObject *) group;

@end

@protocol ParseManagerLoginDelegate <NSObject>
- (void) loginSucceed;
- (void) loginFailWithError:(NSError*) error;
@end

@protocol ParseManagerSignupDelegate <NSObject>
- (void) signupSucceed;
- (void) signupFailWithError:(NSError*) error;
@end

@protocol ParseManagerLoadingGroupsDelegate <NSObject>
- (void) didLoadGroups:(NSArray *) groups withError:(NSError *) error;
@end

@protocol ParseManagerAddGroupDelegate <NSObject>
- (void) didAddGroupWithError:(NSError *) error;
@end

@protocol ParseManagerGetUserGroups <NSObject>
- (void) didLoadUserGroups:(NSArray *)groups WithError:(NSError *) error;
@end

@protocol ParseManagerUpdateGroupDelegate<NSObject>

@optional
- (void) didUpdateGroupData:(BOOL) succeed;
- (void) didAddUserToGroup:(BOOL) succeed;
- (void) didRemoveUserFromGroup:(BOOL) succeed;
- (void) groupNameExist:(BOOL) exist;
- (void) didFailWithError:(NSError *)error;

@end

@protocol ParseManagerFailureDelegate <NSObject>
- (void) didFailWithError:(NSError *) error;
@end

@protocol ParseManagerDelegate <NSObject>
- (void) didloadAllObjects:(NSArray *) objects;
- (void) didFailWithError:(NSError *) error;
@end

@protocol ParseManagerDeleteDelegate <NSObject>
- (void) didDeleteObject:(BOOL) succeeded;
@end

@protocol ParseManagerLoadNewUsers <NSObject>
- (void) didloadNewUsers:(NSArray *)users WithError:(NSError *) error;
@end

@protocol ParseManagerGetTentativeUsers <NSObject>
- (void) didLoadTentativeUsers:(NSArray *)tentativeUsers;
@end

@protocol ParseManagerGetAllOtherGroups <NSObject>
- (void) didLoadAllOtherGroups:(NSArray *)allGroups;
@end

@protocol ParseManagerGetFacebookFriendsDelegate <NSObject>
- (void) didLoadFacebookFriends:(NSArray *)friends withError:(NSError *)error;
@end

@protocol ParseManagerGetNearUsersDelegate <NSObject>
- (void) didLoadNearUsers:(int)userCount forGroup:(PFObject *)group withError:(NSError *) error;
@end