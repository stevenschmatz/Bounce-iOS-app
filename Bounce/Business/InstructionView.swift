//
//  InstructionView.swift
//  Bounce
//
//  Created by Steven on 6/18/15.
//  Copyright (c) 2015 Bounce Labs, Inc. All rights reserved.
//

import UIKit
import Parse

class InstructionView: UIViewController {
    
    // MARK: - Initializers
    
    init(title: String, bodyText text: String, imageFile fileName: String, pageIndex index: Int) {
        self.index = index
        self.titleName = title
        self.bodyText = text
        self.image = UIImage(named: fileName)

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.index = 0
        self.titleName = ""
        self.bodyText = ""
        self.image = UIImage()
        
        super.init(coder: aDecoder)
    }
    
    // MARK: - Variables
    
    let index: Int
    let titleName: String
    let bodyText: String
    let image: UIImage!
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: self.image)
        self.view.addSubview(imageView)
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = self.titleName
        titleLabel.textAlignment = .Center
        titleLabel.font = Constants.Fonts.Avenir.Large

        self.view.addSubview(titleLabel)
        return titleLabel
    }()
    
    private lazy var contentLabel: UILabel = {
        let contentLabel = UILabel()
        
        contentLabel.textColor = UIColor.whiteColor()
        contentLabel.text = self.bodyText
        contentLabel.textAlignment = .Center
        contentLabel.lineBreakMode = .ByWordWrapping
        contentLabel.numberOfLines = 0
        contentLabel.font = Constants.Fonts.Avenir.Medium
        
        self.view.addSubview(contentLabel)
        return contentLabel
    }()
    
    private lazy var freepikLabel: UILabel = {
        let freepikLabel = UILabel()
        
        freepikLabel.text = "Designed by Freepik"
        freepikLabel.font = Constants.Fonts.Avenir.Tiny
        freepikLabel.textAlignment = .Right
        freepikLabel.textColor = UIColor(white: 1.0, alpha: 0.3)
        
        freepikLabel.hidden = (self.index != 3)
        
        self.view.addSubview(freepikLabel)
        return freepikLabel
    }()
    
    // MARK: - Autolayout
    
    func layoutSubviews() {
        let screenWidth = CGRectGetWidth(view.bounds)
        let screenHeight = CGRectGetHeight(view.bounds)

        freepikLabel.pinToTopEdgeOfSuperview()
        freepikLabel.pinToRightEdgeOfSuperview()
        
        let imageSize = imageView.image!.size
        
        if (index == 1) {
            imageView.pinToTopEdgeOfSuperview(screenHeight * 0.15)
            imageView.sizeToWidth(screenWidth * 0.9)
            imageView.sizeToHeight(imageSize.height * (screenWidth * 0.9 / imageSize.width))
        } else {
            imageView.pinToTopEdgeOfSuperview(screenHeight * 0.07)
            imageView.sizeToHeight(screenHeight * 0.35)
            imageView.sizeToWidth(imageSize.width * (screenHeight * 0.35 / imageSize.height))
        }
        
        imageView.centerHorizontallyInSuperview()
        
        titleLabel.pinToBottomEdgeOfSuperview(screenHeight * 0.15 + 10)
        titleLabel.pinToSideEdgesOfSuperview()
        
        contentLabel.pinToSideEdgesOfSuperview(screenWidth * 0.1)
        contentLabel.positionBelowItem(titleLabel, offset: 10)
    }
    
    // MARK: - Builtins
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.layoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
