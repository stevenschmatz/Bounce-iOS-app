//
//  RoundedRectButton.swift
//  Bounce
//
//  Created by Steven on 7/22/15.
//  Copyright (c) 2015 Bounce Labs, Inc. All rights reserved.
//

import UIKit

/**
 * A rounded rect, used in the introduction view screens.
 */
class RoundedRectButton: UIButton {
    
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    
    init(text: String) {
        super.init(frame: CGRectMake(0, 0, 0, 0))

        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 1.5
        self.layer.cornerRadius = 10
        
        self.setTitle(text, forState: UIControlState.Normal)
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.titleLabel?.font = Constants.Fonts.Avenir.Medium
        
        indicator.alpha = 0.0
        self.addSubview(indicator)
        indicator.centerInSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 1.5
        self.layer.cornerRadius = 10
    }

    override var highlighted: Bool {
        didSet {
            
            if (highlighted) {
                self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1)
            }
            else {
                self.backgroundColor = UIColor.clearColor()
            }
        }
    }
}
