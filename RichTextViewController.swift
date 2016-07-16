//
//  RichTextViewController.swift
//  bounce
//
//  Created by Steven on 9/5/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

import UIKit

class RichTextViewController: UIViewController {

    private let fileName: String

    private lazy var webView: UIWebView = {
        let _webView = UIWebView()
        
        let url = NSBundle.mainBundle().URLForResource(self.fileName, withExtension: "rtf")
        let request = NSURLRequest(URL: url!)
        _webView.loadRequest(request)
        
        self.view.addSubview(_webView)
        
        return _webView
    }()

    /**
     * Opens an RTF file with the given file name, and sets the navigation bar title.
     *
     * - parameter title: The title of the navigation bar
     * - parameter fileName: The name of the file (without the .rtf extension).
     */
    init(title: String, fileName: String) {
        self.fileName = fileName
        super.init(nibName: nil, bundle: nil)
        self.title = title
        
        webView.pinToEdgesOfSuperview()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let nav = self.navigationController?.navigationBar
        nav?.tintColor = UIColor.whiteColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }

    required init?(coder aDecoder: NSCoder) {
        self.fileName = ""
        super.init(coder: aDecoder)
    }
}
