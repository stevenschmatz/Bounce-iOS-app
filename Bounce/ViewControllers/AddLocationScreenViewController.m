//
//  AddLocationScreenViewController.m
//  bounce
//
//  Created by Robin Mehta on 3/31/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "AddLocationScreenViewController.h"
#import "AddGroupUsersViewController.h"
#import "AppConstant.h"
#import <Parse/Parse.h>
#import "ParseManager.h"
#import <CoreLocation/CoreLocation.h>
#import "Utility.h"
#import "UIView+AutoLayout.h"

@interface AddLocationScreenViewController ()

@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) CLGeocoder *geoCoder;
@property (nonatomic, strong) NSString *address;

@end

@implementation AddLocationScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MKMapView *tempMap = [MKMapView new];
    [self.view addSubview:tempMap];
    [tempMap kgn_pinToEdgesOfSuperview];
    self.map = tempMap;
    
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.backgroundColor = BounceRed;
    
    UILabel *navLabel = [UILabel new];
    navLabel.textColor = [UIColor whiteColor];
    navLabel.backgroundColor = [UIColor clearColor];
    navLabel.textAlignment = NSTextAlignmentCenter;
    navLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:20];
    self.navigationItem.titleView = navLabel;
    navLabel.text = @"Set Location";
    [navLabel sizeToFit];
    
    UIButton *customButton = [[Utility getInstance] createCustomButton:[UIImage imageNamed:@"common_back_button"]];
    [customButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customButton];
    
    UIButton *rightButton = [[Utility getInstance] createCustomButton:[UIImage imageNamed:@"whiteCheck"]];
    [rightButton addTarget:self action:@selector(doneButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    UIView *bottomView = [UIView new];
    bottomView.hidden = YES;
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.map addSubview:bottomView];
    [bottomView kgn_pinToBottomEdgeOfSuperviewWithOffset:TAB_BAR_HEIGHT];
    [bottomView kgn_pinToLeftEdgeOfSuperview];
    [bottomView kgn_sizeToHeight:100];
    [bottomView kgn_sizeToWidth:self.view.frame.size.width];
    self.bottomView = bottomView;
    
    UILabel *address = [[UILabel alloc] init];
    address.textColor = [UIColor blackColor];
    address.numberOfLines = 0;
    address.textAlignment = NSTextAlignmentCenter;
    address.font = [UIFont fontWithName:@"AvenirNext-Regular" size:16.0];
    [self.bottomView addSubview:address];
    [address kgn_pinToTopEdgeOfSuperviewWithOffset:30];
    [address kgn_centerHorizontallyInSuperview];
    [address kgn_sizeToWidth:self.view.frame.size.width - 50];
    self.addressLabel = address;
    
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapClicked:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    
    [self.map addGestureRecognizer:tapRecognizer];
    [self.map setDelegate:self];
    self.geoCoder = [CLGeocoder new];
    
    [self startReceivingSignificantLocationChanges];
    [self changeCenterToUserLocation];
    [self setUserTrackingMode];
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
-(IBAction)mapClicked:(UITapGestureRecognizer *)recognizer {
    CGPoint clickedPoint = [recognizer locationInView:self.map];
    CLLocationCoordinate2D tapPoint = [self.map convertPoint:clickedPoint toCoordinateFromView:self.map];
    
    MKPointAnnotation *mkPointClicked = [[MKPointAnnotation alloc] init];
    
    mkPointClicked.coordinate = tapPoint;
    NSLog(@"%f , %f", clickedPoint.x, clickedPoint.y);
    NSLog(@"%f", mkPointClicked.coordinate.latitude);
    NSLog(@"%f", mkPointClicked.coordinate.longitude);
    
    MKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake(mkPointClicked.coordinate.latitude,
                                               mkPointClicked.coordinate.longitude);
    MKCoordinateSpan span;
    span.latitudeDelta = 0.1;
    span.longitudeDelta = 0.1;
    
    region.span = span;
    NSArray *existingpoints = self.map.annotations;
    if ([existingpoints count])
        [self.map removeAnnotations:existingpoints];
    [self.map addAnnotation:mkPointClicked];
    self.groupLocation = [PFGeoPoint geoPointWithLatitude:mkPointClicked.coordinate.latitude longitude:mkPointClicked.coordinate.longitude];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:mkPointClicked.coordinate.latitude longitude:mkPointClicked.coordinate.longitude];
    [[Utility getInstance] showProgressHudWithMessage:@"Locating..."];
    [self.geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        self.address = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"]componentsJoinedByString:@", "];
        
        MAKE_A_WEAKSELF;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.addressLabel.text = [NSString stringWithFormat:@"Centered at %@", self.address];
            [[Utility getInstance] hideProgressHud];
            weakSelf.bottomView.hidden = NO;
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cancelButtonClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)doneButtonClicked{
    if (self.groupLocation) {
        [self getAllUsers];
    }
    else{
        [[Utility getInstance] showAlertMessage:@"Tap the map to set your location!"];
    }
}

- (void) getAllUsers
{
    if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
        [[Utility getInstance] showProgressHudWithMessage:COMMON_HUD_LOADING_MESSAGE];
        [[ParseManager getInstance] setDelegate:self];
        [[ParseManager getInstance] getAllUsers];
    }
}

#pragma mark - Parse Manager Delegate
- (void)didloadAllObjects:(NSArray *)objects
{
    [[Utility getInstance] hideProgressHud];
    NSMutableArray *users  = [[NSMutableArray alloc] initWithArray:objects];
    [self navigateToGroupUsersScreenAndSetData:([NSArray arrayWithArray:users])];
}

- (void)didFailWithError:(NSError *)error
{
    [[Utility getInstance] hideProgressHud];
    NSLog(@"Error in loading users from parse.com");
}

-(void) navigateToGroupUsersScreenAndSetData:(NSArray *) users{
    AddGroupUsersViewController *controller = [[AddGroupUsersViewController alloc]  init];
    controller.candidateUsers = users;
    controller.homepointImage = self.homepointImage;
    controller.groupLocation = self.groupLocation;
    controller.groupName = self.groupName;
    controller.address = self.address;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark Custom Functions

/// MODIFIES: The location manager
/// EFFECTS:  Starts the Core Location manager monitoring for significant
///           location changes, to preserve battery life.
- (void)startReceivingSignificantLocationChanges {
    if (nil == self.location_manager) {
        self.location_manager = [[CLLocationManager alloc] init];
    }
    
    self.location_manager.delegate = self;
    self.location_manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.location_manager.distanceFilter = 10; // meters.. not sure if this will work well?
    [self.location_manager startMonitoringSignificantLocationChanges];
}

/// MODIFIES: self.map
/// EFFECTS:  Sets the user tracking mode to be constantly set around the
///           user.
- (void)setUserTrackingMode {
    [self.map setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}

- (void)changeCenterToUserLocation {
    MKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake(self.location_manager.location.coordinate.latitude,
                                               self.location_manager.location.coordinate.longitude);
    
    MKCoordinateSpan span;
    span.latitudeDelta = 0.01;
    span.longitudeDelta = 0.01;
    
    region.span = span;
    [self.map setRegion:region];
}

/// Called when a significant location change occurs.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self foundLocation:manager.location];
}

/// Called when an error occurs
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location manager failed with error: %@", error);
}

/// Called when the location is updated.
- (void)foundLocation:(CLLocation *)location
{
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLocation:location];
    PFUser *currentUser = [PFUser currentUser];
    currentUser[@"CurrentLocation"] = geoPoint;
    [currentUser saveInBackground];
}
#pragma mark - MapView delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        // Try to dequeue an existing pin view first.
        MKAnnotationView *pinView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView) {
            // If an existing pin view was not available, create one.
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            UIView *customView = [self createCustomPinAnnotaionView];
            customView.center = pinView.center;
            [pinView addSubview:customView];
            
        } else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

#pragma mark - Create Custom view pin annotaion
- (UIView*) createCustomPinAnnotaionView
{
    @try {
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, INNER_VIEW_ICON_RADIUS, INNER_VIEW_ICON_RADIUS)];
        // circular icon view
        UIView *innerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, INNER_VIEW_RADIUS, INNER_VIEW_RADIUS)];
        [imageview setContentMode:UIViewContentModeScaleToFill];
        imageview.image = [UIImage imageNamed:@"nav_bar_profile_menu_icon"];
        //innerView.backgroundColor = BounceRed;
        // Add icon image to the inner view
        imageview.center = innerView.center;
        [innerView addSubview:imageview];
        [[Utility getInstance] addRoundedBorderToView:innerView];
        //Outer view
        UIView *outerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, OUTER_VIEW_RADIUS, OUTER_VIEW_RADIUS)];
        outerView.backgroundColor = CUSTOM_ANNOTAION_OVERLAY_COLOR;
        [[Utility getInstance] addRoundedBorderToView:outerView];
        // Add inner view to the outer view
        innerView.center = outerView.center;
        [outerView addSubview:innerView];
        return outerView;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

@end
