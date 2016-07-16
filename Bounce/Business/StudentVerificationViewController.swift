//
//  StudentVerificationViewController.swift
//  Bounce
//
//  Created by Steven on 7/22/15.
//  Copyright (c) 2015 Bounce Labs, Inc. All rights reserved.
//

import UIKit

class StudentVerificationViewController: UIViewController, UITextFieldDelegate {
    
    let imageView = UIImageView()
    var textField = UITextField()
    let titleLabel = UILabel()
    let neverShareLabel = UILabel()
    let contentLabel = UILabel()
    let sendVerificationButton = RoundedRectButton(text: "Send verification email")

    var keyboardUp = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        self.view.backgroundColor = Constants.Colors.BounceRed
        
        // Image view
        
        let image = UIImage(named: "Intro-Hat")
        imageView.image = image
        self.view.addSubview(imageView)
        
        let originalSize = image?.size
        imageView.centerHorizontallyInSuperview()
        imageView.pinToTopEdgeOfSuperview(self.view.frame.size.height * 0.05, priority: 1.0)
        
        if (self.view.bounds.size.height <= 480) {
            imageView.pinToSideEdgesOfSuperview(100)
        } else {
            imageView.pinToSideEdgesOfSuperview(self.view.frame.size.width * 0.1 + 50)
        }
        
        let constraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: imageView, attribute: NSLayoutAttribute.Width, multiplier: originalSize!.height / originalSize!.width, constant: 0.0)
        
        self.view.addConstraint(constraint)
        
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "Are you a student?"
        titleLabel.textAlignment = .Center
        titleLabel.font = Constants.Fonts.Avenir.Large
        self.view.addSubview(titleLabel)
        
        titleLabel.centerHorizontallyInSuperview()
        titleLabel.positionBelowItem(imageView, offset: self.view.frame.size.height * 0.025)

        contentLabel.textColor = UIColor.whiteColor()
        contentLabel.text = "In the future, you'll be able to match with other students when bouncin' home."
        contentLabel.textAlignment = .Center
        contentLabel.lineBreakMode = .ByWordWrapping
        contentLabel.numberOfLines = 0
        contentLabel.font = Constants.Fonts.Avenir.Medium
        
        self.view.addSubview(contentLabel)
        
        contentLabel.pinToSideEdgesOfSuperview(self.view.frame.size.height * 0.05)
        contentLabel.positionBelowItem(titleLabel, offset: 20)
        
        // Text Field

        let textFieldHeight: CGFloat = 53
        textField.backgroundColor = UIColor.whiteColor()
        let paddingView = UIView(frame: CGRectMake(0,0,15,textFieldHeight))
        textField.leftView = paddingView
        textField.leftViewMode = UITextFieldViewMode.Always
        textField.font = Constants.Fonts.Avenir.Medium
        textField.placeholder = "Enter your .edu email address"
        textField.returnKeyType = UIReturnKeyType.Send
        textField.keyboardType = UIKeyboardType.EmailAddress
        textField.autocorrectionType = UITextAutocorrectionType.No
        textField.addTarget(self, action: Selector("checkEmailField"), forControlEvents: UIControlEvents.EditingDidEndOnExit)
        
        self.view.addSubview(textField)

        textField.positionBelowItem(contentLabel, offset: self.view.bounds.height * 0.05)
        textField.sizeToHeight(textFieldHeight)
        textField.pinToSideEdgesOfSuperview(40)
        textField.autocapitalizationType = UITextAutocapitalizationType.None
        
        neverShareLabel.textColor = UIColor.whiteColor()
        neverShareLabel.text = "We never share this with anyone."
        neverShareLabel.textAlignment = .Center
        neverShareLabel.font = Constants.Fonts.Avenir.Small
        self.view.addSubview(neverShareLabel)
        
        neverShareLabel.centerHorizontallyInSuperview()
        neverShareLabel.positionBelowItem(textField, offset: 15)
        
        if (self.view.bounds.size.height <= 480) {
            neverShareLabel.hidden = true;
        }
        
        // Send Verification Button
        
        sendVerificationButton.addTarget(self, action: Selector("checkEmailField"), forControlEvents: .TouchUpInside)
        self.view.addSubview(sendVerificationButton)
        
        sendVerificationButton.pinToBottomEdgeOfSuperview(50)
        sendVerificationButton.sizeToHeight(53)
        sendVerificationButton.pinToSideEdgesOfSuperview(30)
        
        // Animations
        
        contentLabel.alpha = 0.0
        textField.alpha = 0.0
        neverShareLabel.alpha = 0.0
        sendVerificationButton.alpha = 0.0
        
        // Dismisses the keyboard if the user taps outside of the keyboard region.
        let tap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        if animated {
            UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.contentLabel.alpha = 1.0
                self.textField.alpha = 1.0
                self.neverShareLabel.alpha = 1.0
                self.sendVerificationButton.alpha = 1.0
                }, completion: nil
            )
        }
    }
    
    // Dismisses the keyboard.
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if keyboardUp {
            return
        }

        if let info = notification.userInfo {
            let movementHeight = -(info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue().size.height
            UIView.beginAnimations("keyboardGoinUP", context: nil)
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationDuration(0.3)
            UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: info[UIKeyboardAnimationCurveUserInfoKey]!.integerValue)!)
            self.view.frame = CGRectOffset(self.view.frame, 0, movementHeight + (self.view.frame.maxY - neverShareLabel.frame.maxY - 10))
            UIView.commitAnimations()

            keyboardUp = true
        } else {
            print("Error: No user info for keyboardWillShow")
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if !keyboardUp {
            return
        }

        if let info = notification.userInfo {
            UIView.beginAnimations("keyboardGoinDOWN", context: nil)
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationDuration(0.3)
            UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: info[UIKeyboardAnimationCurveUserInfoKey]!.integerValue)!)
            self.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
            UIView.commitAnimations()

            keyboardUp = false
        } else {
            print("Error: No user info for keyboardWillShow")
        }
    }

    // Called when the user wants to send a verification email
    func checkEmailField() {
        if let _ = self.textField.text!.rangeOfString("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.+-]+\\.edu$", options: .RegularExpressionSearch) {
            self.sendVerificationEmail()
        } else {
            let alertController = UIAlertController(
                title: "Email address invalid",
                message: "It seems like the email address is not a valid '.edu' email address. Please check and try again.",
                preferredStyle: UIAlertControllerStyle.Alert
            )
            
            let continueAction = UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(continueAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func sendVerificationEmail() {
        self.resignFirstResponder()
        let user = PFUser.currentUser()!
        
        user.email = textField.text
        user.setValue(true, forKey: "setupComplete")
        user.saveInBackgroundWithBlock(nil)

        self.view.layoutIfNeeded()
        
        let originalSize = imageView.image!.size
        imageView.pinToTopEdgeOfSuperview(self.view.frame.size.height * 0.25 - 100, priority: 2.0)
        let constraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: imageView, attribute: NSLayoutAttribute.Width, multiplier: originalSize.height / originalSize.width, constant: 0.0)
        imageView.pinToSideEdgesOfSuperview(self.view.frame.size.width * 0.20)
        
        self.view.addConstraint(constraint)
        
        UIView.animateWithDuration(0.15, delay: 0.20, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.titleLabel.alpha = 0.0
                self.contentLabel.alpha = 0.0
                self.textField.alpha = 0.0
                self.neverShareLabel.alpha = 0.0
                self.sendVerificationButton.alpha = 0.0
                self.imageView.alpha = 0.5
            }, completion: nil
        )
        
        UIView.animateWithDuration(0.25, delay: 0.35, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.view.layoutIfNeeded()
            }, completion: { Bool -> Void in
                self.presentViewController(EmailSentViewController(), animated: false, completion: nil)
        })
    }
}