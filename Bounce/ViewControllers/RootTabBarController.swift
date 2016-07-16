//
//  RootTabBarController.swift
//  Scroll View
//
//  Created by Steven on 8/5/15.
//  Copyright (c) 2015 Bounce Labs, Inc. All rights reserved.
//

import UIKit

@objc protocol RootTabBarControllerDelegate {
    func setHomepointNotification(notificationPresent: Bool)
    func setTripsNotification(notificationPresent: Bool)
    func setTabBarHidden(hidden: Bool)
}

@objc public enum InitialTab: Int {
    case Homepoints
    case Trips
}

@objc public class RootTabBarController: UIViewController, RootTabBarControllerDelegate {
    private let homeScreenViewController = HomeScreenViewController()
    private let groupsListViewController = GroupsListViewController()
    
    private var hasHomepointsNotifications: Bool = false {
        didSet {
            var displayType: Tab.DisplayType
            let homepointsTabSelected = self.selectedTab?.viewController == self.homepointsTab.viewController

            if self.hasHomepointsNotifications && homepointsTabSelected {
                displayType = .SelectedNotification
            } else if self.hasHomepointsNotifications && !homepointsTabSelected {
                displayType = .NormalNotification
            } else if !self.hasHomepointsNotifications && homepointsTabSelected {
                displayType = .Selected
            } else {
                displayType = .Normal
            }
            
            self.homepointsTab.displayType = displayType
        }
    }
    
    private var hasTripsNotifications: Bool = false {
        didSet {
            var displayType: Tab.DisplayType
            let tripsTabSelected = self.selectedTab?.viewController == self.tripsTab.viewController
            
            if self.hasTripsNotifications && tripsTabSelected {
                displayType = .SelectedNotification
            } else if self.hasTripsNotifications && !tripsTabSelected {
                displayType = .NormalNotification
            } else if !self.hasTripsNotifications && tripsTabSelected {
                displayType = .Selected
            } else {
                displayType = .Normal
            }
            
            self.tripsTab.displayType = displayType
        }
    }
        
    private let initialTab: InitialTab
    
    init(initialTab: InitialTab) {
        self.initialTab = initialTab
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        self.initialTab = InitialTab.Trips
        super.init(coder: aDecoder)
    }
    
    // MARK: - Tabs
    
    struct Tab {
        enum DisplayType {
            case Normal
            case Selected
            case NormalNotification
            case SelectedNotification
        }
        
        var displayType: DisplayType = .Normal {
            didSet {
                switch self.displayType {
                case .Normal:
                    self.barButtonItem.image = self.image
                case .Selected:
                    self.barButtonItem.image = self.selectedImage
                case .NormalNotification:
                    self.barButtonItem.image = self.imageWithNotifications
                case .SelectedNotification:
                    self.barButtonItem.image = self.selectedImageWithNotifications
                }
            }
        }
        
        let viewController: UIViewController
        let barButtonItem: UIBarButtonItem
        let image: UIImage?
        let selectedImage: UIImage?
        let imageWithNotifications: UIImage?
        let selectedImageWithNotifications: UIImage?
        
        init(viewController: UIViewController, imageNamed imageName: String) {
            self.viewController = viewController
            image = UIImage(named: "Tabs-\(imageName)")?.imageWithRenderingMode(.AlwaysOriginal)
            selectedImage = UIImage(named: "Tabs-\(imageName)-Selected")?.imageWithRenderingMode(.AlwaysOriginal)
            imageWithNotifications = UIImage(named: "Tabs-\(imageName)-Notification")?.imageWithRenderingMode(.AlwaysOriginal)
            selectedImageWithNotifications = UIImage(named: "Tabs-\(imageName)-Selected-Notification")?.imageWithRenderingMode(.AlwaysOriginal)
            barButtonItem = UIBarButtonItem(image: image, style: .Plain, target: nil, action: nil)
        }
        
        mutating func setDisplayType(displayType: DisplayType) {
            self.displayType = displayType
        }
    }
    
    private lazy var homepointsTab: Tab = {
        self.groupsListViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: self.groupsListViewController)
        var tab = Tab(viewController: navigationController, imageNamed: "Homepoints")
        tab.barButtonItem.target = self
        tab.barButtonItem.action = "selectTabWithBarButtonItem:"
        return tab
    }()
    
    private lazy var tripsTab: Tab = {
        self.homeScreenViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: self.homeScreenViewController)
        var tab = Tab(viewController: navigationController, imageNamed: "Trips")
        tab.barButtonItem.target = self
        tab.barButtonItem.action = "selectTabWithBarButtonItem:"
        return tab
    }()
    
    private lazy var tabs: [Tab] = [self.homepointsTab, self.tripsTab]
    
    private lazy var accountBarButtonItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "Tabs-Account")?.imageWithRenderingMode(.AlwaysOriginal), style: .Plain, target: self, action: "presentSettings:")
    
    private var selectedTab: Tab? {
        didSet {
            let homepointsTabSelected: Bool = (selectedTab?.viewController == homepointsTab.viewController)
            
            if selectedTab?.viewController == oldValue?.viewController {
                return
            } else {
                // Handle the old values
                if let viewController = oldValue?.viewController {
                    viewController.beginAppearanceTransition(false, animated: false)
                    
                    if homepointsTabSelected {
                        self.tripsTab.displayType = self.hasTripsNotifications ? .NormalNotification : .Normal
                    } else {
                        self.homepointsTab.displayType = self.hasHomepointsNotifications ? .NormalNotification : .Normal
                    }
                    
                    viewController.view.removeFromSuperview()
                    viewController.endAppearanceTransition()
                }
                
                // Handle the new values
                if let viewController = selectedTab?.viewController {
                    viewController.beginAppearanceTransition(true, animated: false)
                    
                    if homepointsTabSelected {
                        self.homepointsTab.displayType = self.hasHomepointsNotifications ? .SelectedNotification : .Selected
                    } else {
                        self.tripsTab.displayType = self.hasTripsNotifications ? .SelectedNotification : .Selected
                    }
                    
                    viewController.view.frame = self.view.bounds
                    view.addSubview(viewController.view)
                    viewController.endAppearanceTransition()
                }
                setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    private var selectedViewController: UIViewController? {
        return selectedTab?.viewController
    }
    
    @objc public class func rootTabBarControllerWithNavigationController(initialTab: InitialTab) -> UIViewController {
        let rootVC = RootTabBarController(initialTab: initialTab)
        (UIApplication.sharedApplication().delegate as! AppDelegate).rootTabBarControllerDelegate = rootVC
        let navigationController = UINavigationController(rootViewController: rootVC)
        navigationController.navigationBarHidden = true
        navigationController.toolbarHidden = false
        return navigationController
    }
    
    @objc private func selectTabWithBarButtonItem(barButtonItem: UIBarButtonItem) {
        selectedTab = first(tabs) { $0.barButtonItem == barButtonItem }
    }
    
    @objc private func presentSettings(sender: UIBarButtonItem) {
        let accountViewController = AccountViewController()
        let navigationController = UINavigationController(rootViewController: accountViewController)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "dismissSettings")
        doneButton.tintColor = UIColor.whiteColor()
        
        let attributes = [NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 19)!]

        doneButton.setTitleTextAttributes(attributes, forState: UIControlState.Normal)
        accountViewController.navigationItem.rightBarButtonItem = doneButton

        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    @objc private func dismissSettings() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    public override func loadView() {
        super.loadView()

        each(tabs.map { $0.viewController }) {
            $0.willMoveToParentViewController(self)
            self.addChildViewController($0)
            $0.didMoveToParentViewController(self)
        }
        
        switch initialTab {
        case InitialTab.Homepoints:
            selectTabWithBarButtonItem(homepointsTab.barButtonItem)
        case InitialTab.Trips:
            selectTabWithBarButtonItem(tripsTab.barButtonItem)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        UIApplication.sharedApplication().statusBarHidden = false
        self.navigationController?.navigationBar.translucent = false
        
        let flexibleSpacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let sideSpacer = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        sideSpacer.width = 30

        self.setToolbarItems({
                return [sideSpacer] + self.tabs.flatMap { [$0.barButtonItem, flexibleSpacer] } + [self.accountBarButtonItem, sideSpacer]
            }(), animated: false)
    }
    
    public override func childViewControllerForStatusBarHidden() -> UIViewController? {
        return selectedViewController
    }
    
    public override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return selectedViewController
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc public func setTabBarHidden(hidden: Bool) {
        self.navigationController?.toolbarHidden = hidden
    }
    
    @objc public func setHomepointNotification(notificationPresent: Bool) {
        self.hasHomepointsNotifications = notificationPresent
    }

    @objc public func setTripsNotification(notificationPresent: Bool) {
        self.hasTripsNotifications = notificationPresent
    }
}
