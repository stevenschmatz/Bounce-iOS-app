//
//  EmailSentViewController.swift
//  Bounce
//
//  Created by Steven on 7/26/15.
//  Copyright (c) 2015 Bounce Labs, Inc. All rights reserved.
//

import UIKit

class EmailSentViewController: UIViewController {
    
    let imageView = UIImageView()
    let getStartedButton = RoundedRectButton(text: "Get started!")
    let titleLabel = UILabel()
    let contentLabel = UILabel()
    
    override func viewDidLoad() {
        self.view.backgroundColor = Constants.Colors.BounceRed
        
        getStartedButton.addTarget(self, action: Selector("presentMainViewController"), forControlEvents: .TouchUpInside)
        getStartedButton.alpha = 0.0
        self.view.addSubview(getStartedButton)
        
        getStartedButton.pinToBottomEdgeOfSuperview(50)
        getStartedButton.sizeToHeight(53)
        getStartedButton.pinToSideEdgesOfSuperview(30)
        
        // Image view
        
        let image = UIImage(named: "Intro-Hat-Green")
        imageView.image = image
        self.view.addSubview(imageView)
        
        let originalSize = image?.size
        imageView.centerHorizontallyInSuperview()
        imageView.pinToTopEdgeOfSuperview(self.view.frame.size.height * 0.25 - 100)
        imageView.pinToSideEdgesOfSuperview(self.view.frame.size.width * 0.20)
        imageView.alpha = 0.5
        
        let constraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: imageView, attribute: NSLayoutAttribute.Width, multiplier: originalSize!.height / originalSize!.width, constant: 0.0)
        
        self.view.addConstraint(constraint)
        
        // Title and Content Labels
        
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "Email sent!"
        titleLabel.textAlignment = .Center
        titleLabel.font = Constants.Fonts.Avenir.Large
        self.view.addSubview(titleLabel)
        
        titleLabel.centerHorizontallyInSuperview()
        titleLabel.positionBelowItem(imageView, offset: self.view.frame.size.height * 0.025)
        
        contentLabel.textColor = UIColor.whiteColor()
        contentLabel.text = "To verify that you’re a student, go to the link that we sent you via email."
        contentLabel.textAlignment = .Center
        contentLabel.lineBreakMode = .ByWordWrapping
        contentLabel.numberOfLines = 0
        contentLabel.font = Constants.Fonts.Avenir.Medium
        
        self.view.addSubview(contentLabel)
        
        contentLabel.pinToSideEdgesOfSuperview(self.view.frame.size.height * 0.05)
        contentLabel.positionBelowItem(titleLabel, offset: 20)
    }
    
    override func viewDidAppear(animated: Bool) {
        if animated {
            UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.imageView.alpha = 1.0
                self.getStartedButton.alpha = 1.0
                }, completion: nil
            )
        }
    }
    
    func presentMainViewController() {
        self.presentViewController(RootTabBarController.rootTabBarControllerWithNavigationController(InitialTab.Homepoints), animated: true, completion: nil)
    }
}
