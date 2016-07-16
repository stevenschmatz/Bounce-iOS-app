//
//  Tutorial.swift
//  bounce
//
//  Created by Robin Mehta on 6/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

import UIKit
import Parse

let BounceRed = UIColor(red: 255/255.0, green: 127/255.0, blue: 127/255.0, alpha: 1.0)    // #FF7F7F
struct Fonts {
    struct Avenir {
        static let Large = UIFont(name: "AvenirNext-Medium", size: 26)
        static let Medium = UIFont(name: "AvenirNext-Regular", size: 18)
        static let Small = UIFont(name: "AvenirNext-Regular", size: 14)
        static let Tiny = UIFont(name: "AvenirNext-Regular", size: 12)
    }
}
class Tutorial: UIViewController, UIPageViewControllerDataSource {
    // MARK: - Page View Controller Content
    
    var pageViewController : UIPageViewController?
    var pageTitles : Array<String> = ["Meet Bounce.", "Join some homepoints!", "Go out and have fun!", "Get home with new friends!"]
    var pageImages : Array<String> = ["Intro-Meet-Bounce", "Intro-Houses", "Intro-Glasses", "Intro-People"]
    var pageContent: Array<String> = [
        "Find friends and neighbors to walk home with when out late.",
        "Join trusted community groups, like neighborhoods or dorms.",
        "Go to that party your friend invited you to – and have a lot of fun without worrying about how to get back.",
        "Bounce connects you with people you can trust near you, so you don’t have to get home alone!"
    ]
    var currentIndex : Int = 0
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.disableSlidePanGestureForLeftMenu();
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.setBackgroundColor()
        self.renderLoginButton()
        self.renderPageViewController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Element Rendering
    
    func setBackgroundColor() {
        UIApplication.sharedApplication().statusBarHidden = true
        self.view.backgroundColor = BounceRed
    }
    
    func renderLoginButton() {
        let loginButton = UIButton()
        let width : CGFloat = 0.85 * self.view.frame.width
        let height : CGFloat = 53
        let distanceFromBottom : CGFloat = 50
        
        loginButton.frame = CGRectMake(
            (self.view.frame.width - width)/2,
            (self.view.frame.height - (height + distanceFromBottom)),
            width,
            height
        )
        
        loginButton.layer.borderColor = UIColor.whiteColor().CGColor
        loginButton.layer.borderWidth = 1.5
        loginButton.layer.cornerRadius = 10
        
        loginButton.setTitle("Log in with Facebook", forState: UIControlState.Normal)
        loginButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        loginButton.setTitleColor(UIColor(red: 255.0, green: 255.0, blue: 255.0, alpha: 0.5), forState: UIControlState.Highlighted)
        loginButton.titleLabel?.font = Fonts.Avenir.Medium
        
        let facebookImage = UIImage(named: "Facebook-Rounded-Square")
        let facebookImageView = UIImageView(image: facebookImage)
        facebookImageView.frame = CGRectMake(height * 0.2, height * 0.2, height * 0.6, height * 0.6);
        loginButton.addSubview(facebookImageView)
        
        loginButton.addTarget(self, action: "loginButtonPressed:", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(loginButton)
    }
    
    func renderPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageViewController!.dataSource = self
        
        let startingViewController: InstructionView = viewControllerAtIndex(0)!
        let viewControllers: NSArray = [startingViewController]
        pageViewController!.setViewControllers(viewControllers as [AnyObject], direction: .Forward, animated: false, completion: nil)
        pageViewController!.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height * 0.8);
        
        addChildViewController(pageViewController!)
        view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
    }
    
    // MARK: - Page View Controller Functions
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! InstructionView).pageIndex
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index--
        
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! InstructionView).pageIndex
        
        if index == NSNotFound {
            return nil
        }
        
        index++
        
        if (index == self.pageTitles.count) {
            return nil
        }
        
        return viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(index: Int) -> InstructionView?
    {
        if self.pageTitles.count == 0 || index >= self.pageTitles.count
        {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        let pageContentViewController = InstructionView()
        pageContentViewController.imageFile = pageImages[index]
        pageContentViewController.titleText = pageTitles[index]
        pageContentViewController.bodyText  = pageContent[index]
        pageContentViewController.pageIndex = index
        currentIndex = index
        
        return pageContentViewController
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return self.pageTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return 0
    }
    
    func loginButtonPressed(sender: UIButton!) {
        let fbLogin = FacebookLogin(navigationController: self.navigationController)
        fbLogin.facebookLogin()
        
    }
}