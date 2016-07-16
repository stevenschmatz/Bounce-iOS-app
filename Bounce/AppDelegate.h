//
//  AppDelegate.h
//  hobble.1.1
//
//  Created by Robin Mehta on 8/7/14.
//  Copyright (c) 2014 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

static NSString * const ParseUsername = @"username";
static NSString * const ParseFriendRelation = @"friendsRelation";
static NSString * const ParseGroupRelation = @"groupsRelation";
static NSString * const ParseGroupName = @"groupName";

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) id rootTabBarControllerDelegate;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end