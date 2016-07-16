//
//  HomePointSuccessfulCreationViewController.m
//  bounce
//
//  Created by Robin Mehta on 3/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "HomePointSuccessfulCreationViewController.h"
#import "AppConstant.h"
#import "GroupsListViewController.h"
#import "UIView+AutoLayout.h"

// TODO: test with different device sizes.

@interface HomePointSuccessfulCreationViewController ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *headerDescription;
@property (strong, nonatomic) UIImageView *imageView;
@property (nonatomic) CGFloat imageHeight;
@property (nonatomic, strong) UILabel *knowYourPeople;
@property (nonatomic, strong) UILabel *whoWouldYouAllowInside1;
@property (nonatomic, strong) UILabel *whoWouldYouAllowInside2;
@property (nonatomic, strong) UIButton *done;

@end

@implementation HomePointSuccessfulCreationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    self.view.backgroundColor = BounceRed;
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"HOME, SWEET HOME";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:24];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel sizeToFit];
    _titleLabel = titleLabel;
    [self.view addSubview:self.titleLabel];
    
    UILabel *headerDescription = [UILabel new];
    headerDescription.textAlignment = NSTextAlignmentCenter;
    headerDescription.text = @"Homepoints are the centerpieces of trusted communities & neighborhoods!";
    headerDescription.textColor = [UIColor whiteColor];
    headerDescription.font = [UIFont fontWithName:@"AvenirNext-Regular" size:16];
    headerDescription.numberOfLines = 0;
    headerDescription.backgroundColor = [UIColor clearColor];
    //[headerDescription sizeToFit];
    _headerDescription = headerDescription;
    [self.view addSubview:self.headerDescription];
    
    UIImageView *imageView = [UIImageView new];
    UIImage *image = [UIImage imageNamed:@"createHP"];
    imageView.image = image;
    _imageHeight = image.size.height;
    _imageView = imageView;
    [self.view addSubview:imageView];
    [self.imageView kgn_sizeToWidth:image.size.width];
    [self.imageView kgn_sizeToHeight:image.size.height];
    
    UILabel *knowYourPeople = [UILabel new];
    knowYourPeople.textAlignment = NSTextAlignmentCenter;
    knowYourPeople.text = @"Be sure that only people you know join!";
    knowYourPeople.textColor = [UIColor whiteColor];
    knowYourPeople.font = [UIFont fontWithName:@"AvenirNext-Regular" size:16];
    knowYourPeople.numberOfLines = 0;
    [knowYourPeople sizeToFit];
    _knowYourPeople = knowYourPeople;
    [self.view addSubview:knowYourPeople];
    
    UILabel *whoWouldYouAllowInside1 = [UILabel new];
    whoWouldYouAllowInside1.textAlignment = NSTextAlignmentCenter;
    whoWouldYouAllowInside1.text = @"Think of it like your own home -";
    whoWouldYouAllowInside1.textColor = [UIColor whiteColor];
    whoWouldYouAllowInside1.font = [UIFont fontWithName:@"AvenirNext-Regular" size:14];
    whoWouldYouAllowInside1.numberOfLines = 0;
    [whoWouldYouAllowInside1 sizeToFit];
    _whoWouldYouAllowInside1 = whoWouldYouAllowInside1;
    [self.view addSubview:whoWouldYouAllowInside1];
    
    UILabel *whoWouldYouAllowInside2 = [UILabel new];
    whoWouldYouAllowInside2.textAlignment = NSTextAlignmentCenter;
    whoWouldYouAllowInside2.text = @"who would you allow inside?";
    whoWouldYouAllowInside2.textColor = [UIColor whiteColor];
    whoWouldYouAllowInside2.font = [UIFont fontWithName:@"AvenirNext-Regular" size:14];
    whoWouldYouAllowInside2.numberOfLines = 0;
    [whoWouldYouAllowInside2 sizeToFit];
    _whoWouldYouAllowInside2 = whoWouldYouAllowInside2;
    [self.view addSubview:whoWouldYouAllowInside2];
    
    UIButton *done = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    done.layer.cornerRadius = 0;
    done.tintColor = [UIColor whiteColor];
    done.backgroundColor = BounceSeaGreen;
    [done setTitle:@"LET'S GO!" forState:UIControlStateNormal];
    done.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:18];
    [done addTarget:self action:@selector(sweetButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    _done = done;
    [self.view addSubview:done];
    
    [self setupViewConstraints];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) setupViewConstraints {
    
    [self.titleLabel kgn_centerHorizontallyInSuperview];
    [self.titleLabel kgn_pinToTopEdgeOfSuperviewWithOffset:self.view.frame.size.height/12];
    
    [self.headerDescription kgn_centerHorizontallyInSuperview];
    [self.headerDescription kgn_sizeToWidth:self.view.frame.size.width - 50];
    [self.headerDescription kgn_pinTopEdgeToTopEdgeOfItem:self.titleLabel withOffset:-self.view.frame.size.height/10];
    
    [self.imageView kgn_centerHorizontallyInSuperview];
    [self.imageView kgn_pinTopEdgeToTopEdgeOfItem:self.headerDescription withOffset:-self.view.frame.size.height/10];
    
    [self.knowYourPeople kgn_centerHorizontallyInSuperview];
    [self.knowYourPeople kgn_pinTopEdgeToTopEdgeOfItem:self.imageView withOffset:-(self.imageHeight + self.view.frame.size.height/15)];
    
    [self.whoWouldYouAllowInside1 kgn_centerHorizontallyInSuperview];
    [self.whoWouldYouAllowInside1 kgn_pinTopEdgeToTopEdgeOfItem:self.knowYourPeople withOffset:-self.view.frame.size.height/12];
    
    [self.whoWouldYouAllowInside2 kgn_centerHorizontallyInSuperview];
    [self.whoWouldYouAllowInside2 kgn_pinTopEdgeToTopEdgeOfItem:self.whoWouldYouAllowInside1 withOffset:-25];
    
    [self.done kgn_centerHorizontallyInSuperview];
    [self.done kgn_pinToBottomEdgeOfSuperviewWithOffset:15 + TAB_BAR_HEIGHT];
    [self.done kgn_sizeToHeight:self.view.frame.size.height/13];
    [self.done kgn_sizeToWidth:self.view.frame.size.width/1.8];
}

- (void)sweetButtonClicked {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
