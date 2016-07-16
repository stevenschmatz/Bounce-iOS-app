//
//  InstructionView.swift
//  bounce
//
//  Created by Robin Mehta on 6/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

import Foundation
import UIKit
import Parse

class InstructionView: UIViewController {
    
    var pageIndex : Int = 0
    var titleText : String = ""
    var bodyText  : String = ""
    var imageFile : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.disableSlidePanGestureForLeftMenu();
        let image = UIImage(named: imageFile)
        let imageView = UIImageView()
        self.disableSlidePanGestureForLeftMenu()
        // The image is lopsided
        if (pageIndex == 1) {
            imageView.frame = CGRectMake(view.frame.width * 0.05, view.frame.height * 0.2, view.frame.width * 0.9, view.frame.width * 0.9 / image!.size.width * image!.size.height)
        } else {
            imageView.frame = CGRectMake(view.frame.width * 0.2, view.frame.height * 0.1, view.frame.width * 0.6, view.frame.width * 0.6 / image!.size.width * image!.size.height)
        }
        
        imageView.image = image
        self.view.addSubview(imageView)
        
        let titleLabel = UILabel(frame: CGRectMake(0, view.frame.height - 380, view.frame.width, 100))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = titleText
        titleLabel.textAlignment = .Center
        titleLabel.font = Fonts.Avenir.Large
        view.addSubview(titleLabel)
        
        let bodyTextHeight : CGFloat = 90
        let bodyTextWidth  : CGFloat = view.frame.width * 0.8
        let bottomOffset   : CGFloat = view.frame.height - 300
        
        let contentLabel = UILabel(frame: CGRectMake(view.frame.width * 0.125, bottomOffset, view.frame.width * 0.75, bodyTextHeight))
        contentLabel.textColor = UIColor.whiteColor()
        contentLabel.text = bodyText
        contentLabel.textAlignment = .Center
        contentLabel.lineBreakMode = .ByWordWrapping
        contentLabel.numberOfLines = 0
        contentLabel.font = Fonts.Avenir.Medium
        view.addSubview(contentLabel)
        
        if (pageIndex == 3) {
            let freepikLabel = UILabel()
            freepikLabel.text = "Designed by Freepik"
            freepikLabel.font = Fonts.Avenir.Tiny
            freepikLabel.textAlignment = .Right
            freepikLabel.frame = CGRectMake(view.frame.width - 150, 0, 150, 20)
            freepikLabel.textColor = UIColor(white: 1.0, alpha: 0.3)
            view.addSubview(freepikLabel)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
