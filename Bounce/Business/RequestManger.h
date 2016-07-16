//
//  RequestManger.h
//  ChattingApp
//
//  Created by Robin Mehta on 3/29/15.
//  Copyright (c) 2015 Bounce Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RequestManagerDelegate;
@protocol RequestManagerCreateRequestDelegate;

@interface RequestManger : NSObject

@property id<RequestManagerDelegate> requestManagerDelegate;
@property id<RequestManagerCreateRequestDelegate> createRequestDelegate;

@property NSInteger unReadReplies;
@property NSInteger requestLeftTimeInMinute;
+ (RequestManger*) getInstance;
- (void) createrequestToGroups:(NSArray *) selectedGroups andGender:(NSString *)gender  withinTime:(NSInteger)timeAllocated andInRadius:(NSInteger) radius;
- (void) endRequest;
- (BOOL) hasActiveRequest;
- (void) loadActiveRequest;
- (void) invalidateCurrentRequest;

@end

@protocol RequestManagerDelegate <NSObject>

- (void) updateRequestRemainingTime:(NSInteger) remainingTime;
- (void) updateRequestUnreadMessage:(NSInteger) numberOfUnreadMessages;
- (void) didEndRequestWithError:(NSError *) error;
- (void) requestTimeOver;
- (void) requestCreated;
//- (void) didLoadActiveRequest;
@end

@protocol RequestManagerCreateRequestDelegate <NSObject>
- (void) didCreateRequestWithError:(NSError *) error;
@end

