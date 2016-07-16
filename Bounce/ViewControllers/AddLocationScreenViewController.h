//
//  AddLocationScreenViewController.h
//  bounce
//
//  Created by Robin Mehta on 3/31/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ParseManager.h"

@interface AddLocationScreenViewController : UIViewController <CLLocationManagerDelegate,MKMapViewDelegate, ParseManagerDelegate>


@property (strong, nonatomic) CLLocationManager *location_manager;
@property (nonatomic, strong) PFGeoPoint * groupLocation;
@property (strong, nonatomic) NSString* groupName;
@property __block NSArray *groupUsers;
@property (strong, nonatomic) UIImage *homepointImage;

@property (weak, nonatomic) MKMapView *map;

@end
