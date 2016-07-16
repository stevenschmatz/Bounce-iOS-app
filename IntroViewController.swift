//
//  IntroViewController.swift
//  Bounce
//
//  Created by Steven on 6/18/15.
//  Copyright (c) 2015 Bounce Labs, Inc. All rights reserved.
//

import UIKit
import Parse
import CoreData

public class IntroViewController: UIViewController, UIPageViewControllerDataSource {
    
    // MARK: - Page View Controller Content
    
    var pageViewController : UIPageViewController?
    
    struct Page {
        var title:     String
        var imageFile: String
        var content:   String
        
        init(title: String, imageTitle: String, content: String) {
            self.title = title
            self.imageFile = imageTitle
            self.content = content
        }
    }
    
    let pages = [
        Page(title: "Meet Bounce.", imageTitle: "Intro-Meet-Bounce", content: "Find friends and neighbors to walk home with when out late."),
        Page(title: "Find your homepoints.", imageTitle: "Intro-Houses", content: "Join trusted community groups, like neighborhoods or dorms."),
        Page(title: "Go out and have fun!", imageTitle: "Intro-Glasses", content: "You'll be matched with others from your homepoints when you're ready to leave."),
        Page(title: "You’re all set!", imageTitle: "Intro-People", content: "Time to bounce home with your new crew.")
    ]
    
    var currentIndex : Int = 0
    
    let loginButton = RoundedRectButton(text: "Log in with Facebook")
    
    // MARK: - Overrides
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.setBackgroundColor()
        self.renderLoginButton()
        self.renderPageViewController()
        
        let button = UIButton()
        button.setTitle("By signing up, you agree to our Terms of Service.", forState: .Normal)
        button.titleLabel?.font = Constants.Fonts.Avenir.Tiny
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.addTarget(self, action: Selector("termsPressed:"), forControlEvents: .TouchUpInside)
        self.view.addSubview(button)
        
        button.centerHorizontallyInSuperview()
        button.positionBelowItem(self.loginButton, offset: 3)
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Element Rendering
    
    func setBackgroundColor() {
        UIApplication.sharedApplication().statusBarHidden = true
        self.view.backgroundColor = Constants.Colors.BounceRed
    }
    
    func renderLoginButton() {
        let height : CGFloat = 53
        
        loginButton.addTarget(self, action: Selector("loginButtonPressed:"), forControlEvents: .TouchUpInside)
        
        let facebookImage = UIImage(named: "Facebook-Rounded-Square")
        let facebookImageView = UIImageView(image: facebookImage)
        facebookImageView.frame = CGRectMake(height * 0.3, height * 0.3, height * 0.4, height * 0.4)
        loginButton.addSubview(facebookImageView)
        
        self.view.addSubview(loginButton)
        
        loginButton.pinToBottomEdgeOfSuperview(CGRectGetHeight(self.view.bounds) * 0.08)
        loginButton.sizeToHeight(53)
        loginButton.pinToSideEdgesOfSuperview(30)
    }
    
    func renderPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageViewController!.dataSource = self
        
        let startingViewController: InstructionView = viewControllerAtIndex(0)!
        let viewControllers: [UIViewController] = [startingViewController]
        pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: nil)
        pageViewController!.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height * 0.8);
        
        addChildViewController(pageViewController!)
        view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
    }
    
    // MARK: - Page View Controller Functions
    
    public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! InstructionView).index
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index--
        
        return viewControllerAtIndex(index)
    }
    
    public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! InstructionView).index
        
        if index == NSNotFound {
            return nil
        }
        
        index++
        
        if (index == self.pages.count) {
            return nil
        }
        
        return viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(index: Int) -> InstructionView?
    {
        if self.pages.count == 0 || index >= self.pages.count
        {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        let pageContentViewController = InstructionView(title: pages[index].title, bodyText: pages[index].content, imageFile: pages[index].imageFile, pageIndex: index)
        currentIndex = index
        
        return pageContentViewController
    }
    
    public func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return self.pages.count
    }
    
    public func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return 0
    }
    
    // MARK: - Button Actions
    
    func termsPressed(sender: RoundedRectButton!) {
        let rtfVC = RichTextViewController(title: "Terms of Service", fileName: "TermsOfService")
        let termsViewController = UINavigationController(rootViewController: rtfVC)
        termsViewController.navigationBar.tintColor = Constants.Colors.BounceRed
        termsViewController.navigationBar.backgroundColor = Constants.Colors.BounceRed

        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "dismissSettings")
        doneButton.tintColor = UIColor.whiteColor()
        let attributes = [NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 19)!]
        doneButton.setTitleTextAttributes(attributes, forState: UIControlState.Normal)
        rtfVC.navigationItem.rightBarButtonItem = doneButton

        self.presentViewController(termsViewController, animated: true, completion: nil)
    }
    
    func dismissSettings() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loginButtonPressed(sender: RoundedRectButton!) {
        
        if (Utility.getInstance().checkReachabilityAndDisplayErrorMessage()) {
        
        sender.indicator.startAnimating()
        UIView.animateWithDuration(0.25, animations: {
            sender.titleLabel?.alpha = 0.0
        })
        
        UIView.animateWithDuration(0.25, delay: 0.25, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            sender.indicator.alpha = 1.0
            }, completion: nil)
        
        // FB login
        PFFacebookUtils.logInWithPermissions(["user_friends", "public_profile", "user_about_me", "email"], block: {
            (user: PFUser?, error: NSError?) -> Void in
            
            if user != nil {
                ParsePushUserAssign()
                
                self.loadProfileInfoInBackground()
                
                // New user
                if user!.isNew {
                    self.handleNewUser(user)
                    
                    // Returning user
                } else {
                    // Not set location permissions yet
                    if CLLocationManager.authorizationStatus() == .NotDetermined {
                        self.presentViewController(RequestLocationViewController(), animated: true, completion: nil)
                        
                        // Not set push notifications yet
                    } else if (UIApplication.sharedApplication().currentUserNotificationSettings()!.types == .None) {
                        self.presentViewController(RequestPushNotificationsViewController(), animated: true, completion: nil)
                    }
                    
                    if let setupComplete: Bool = user!.valueForKey("setupComplete") as? Bool {
                        if setupComplete {
                            user!.setValue(true, forKey: "setupComplete")
                            user!.saveInBackgroundWithBlock(nil)
                            self.presentViewController(RootTabBarController.rootTabBarControllerWithNavigationController(InitialTab.Trips), animated: true, completion: nil)
                            return
                        } else {
                            // Not set student status yet
                            self.presentViewController(StudentStatusViewController(animated: false), animated: true, completion: nil)
                        }
                    }
                }
            }
            else if error != nil {
                self.handleLoginFailed(error!)
                
            }
        })
        }
    }
    
    // MARK: - Login Handlers
    
    func handleLoginFailed(error: NSError) {
        print("Login failed with error \(error)")
        
        UIView.animateWithDuration(0.25, animations: {
            self.loginButton.indicator.alpha = 0.0
        })
        
        UIView.animateWithDuration(0.25, delay: 0.25, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.loginButton.titleLabel?.alpha = 1.0
            }, completion: nil)

        
        // TODO: MAKE LOGIN LOADING INDICATOR GO AWAY.
        
        let alertController = UIAlertController(
            title: "Uh oh! Login failed.",
            message: "In Facebook > Settings > Apps, make sure that “Apps, Websites, and Plugins” is enabled.",
            preferredStyle: UIAlertControllerStyle.Alert
        )
        
        let continueAction = UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(continueAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /**
    * Stores user ID and full name in Parse.
    *
    * - parameter user: The new PFUser signing up.
    */
    func handleNewUser(user: PFUser?) {
        FBRequestConnection.startForMeWithCompletionHandler({ (connection: FBRequestConnection!, result: AnyObject?, error: NSError!) -> Void in
            
            // Maps from the /me response value names to stored Parse value names.
            let keyMap = [
                "id":     ["facebookId"],
                "name":   ["fullname", "username"],
                "gender": ["Gender"],
                "email": ["emailCopy"]
            ]
            
            if error != nil {
                print(error)
            } else {
                for (graphAPIResponseKey, parseKeys) in keyMap {
                    for parseKey in parseKeys {
                        if let graphAPIResponseValue = result?.objectForKey(graphAPIResponseKey) as? String {
                            PFUser.currentUser()?.setObject(graphAPIResponseValue, forKey: parseKey)
                            user!.saveInBackgroundWithBlock(nil)
                            
                            if graphAPIResponseKey == "id" {
                                let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                                dispatch_async(dispatch_get_global_queue(priority, 0)) {
                                    self.loadProfilePictureOnMainThread(graphAPIResponseValue)
                                }
                            }
                        }
                    }
                }
            }
        })
        
        user!.setValue(false, forKey: "setupComplete")
        user!.saveInBackgroundWithBlock(nil)
        self.presentViewController(RequestLocationViewController(), animated: true, completion: nil)
    }
    
    func handleReturningUser(user: PFUser?, setupComplete: Bool) {
        // User has entered the app and completed setup
        if setupComplete {
            user!.setValue(true, forKey: "setupComplete")
            user!.saveInBackgroundWithBlock(nil)
            self.presentViewController(RootTabBarController.rootTabBarControllerWithNavigationController(InitialTab.Trips), animated: true, completion: nil)
            
            // User has entered the app and not completed setup
        } else {
            user!.setValue(false, forKey: "setupComplete")
            user!.saveInBackgroundWithBlock(nil)
            self.presentViewController(RequestLocationViewController(), animated: true, completion: nil)
        }
    }
    
    // MARK: - Caching
    
    func loadProfilePictureOnMainThread(id: String!) {
        let pictureURL = NSURL(string: "https://graph.facebook.com/\(id)/picture?type=large")
        let profilePicture = UIImage(data: NSData(contentsOfURL: pictureURL!)!)
        
        let imageData = UIImagePNGRepresentation(profilePicture!)
        
        let photoFile = PFFile(name: "picture.jpg", data: imageData)
        let thumbnailFile = PFFile(name: "thumbnail", data: imageData)
        let user = PFUser.currentUser()
        user["picture"] = photoFile
        user["thumbnail"] = thumbnailFile
        user.saveInBackgroundWithBlock(nil)
    }
    
    func loadProfileInfoInBackground() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let entity =  NSEntityDescription.entityForName("AccountInfo", inManagedObjectContext: managedContext)
        
        let fetchRequest = NSFetchRequest(entityName:"AccountInfo")

        var fetchedResults: [NSManagedObject]
        do {
            fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        } catch _ {
            print("Error executing fetch request")
            fetchedResults = []
            
        }

        var accountInfo: NSManagedObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        
        if let results : [NSManagedObject] = fetchedResults {
            if results.count > 0 {
                accountInfo = results[0]
            }
        }
        
        FBRequestConnection.startForMeWithCompletionHandler({ (connection: FBRequestConnection!, result: AnyObject?, error: NSError!) -> Void in
            if error != nil {
                print(error)
            } else {
                
                // Get user full name
                if let name = result?["name"] as? String {
                    accountInfo.setValue(name, forKey: "name")
                    
                    var error: NSError?
                    do {
                        try managedContext.save()
                    } catch let error1 as NSError {
                        error = error1
                        print("Could not save \(error), \(error?.userInfo)")
                    } catch {
                        fatalError()
                    }
                } else {
                    print("ERROR: Could not get Facebook name")
                }
            }
        })
    }
}

