//
//  PFObject+PFObject_isEqual.m
//  bounce
//
//  Created by Robin Mehta on 4/15/15.
//  Copyright (c) 2015 Bounce Labs, Inc. All rights reserved.
//

#import "PFObject+PFObject_isEqual.h"

@implementation PFObject (PFObject_isEqual)

- (BOOL) isEqual:(id)object
{
    if ([object isKindOfClass:[PFObject class]])
    {
        PFObject* pfObject = object;
        return [self.objectId isEqualToString:pfObject.objectId];
    }
    
    return NO;
}

@end
