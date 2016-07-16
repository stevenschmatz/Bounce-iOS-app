//
//  Constants.swift
//  Bounce
//
//  Created by Steven on 6/18/15.
//  Copyright (c) 2015 Bounce Labs, Inc. All rights reserved.
//

import UIKit

struct Constants {
    struct Colors {
        static let BounceRed = UIColor(red: 255/255.0, green: 127/255.0, blue: 127/255.0, alpha: 1.0)    // #FF7F7F
        static let BounceGreen = UIColor(red: 202/255.0, green: 231/255.0, blue: 185/255.0, alpha: 1.0)  // #CAE7B9
        static let BounceYellow = UIColor(red: 243/255.0, green: 222/255.0, blue: 138/255.0, alpha: 1.0) // #F3DE8A
        static let BounceBlue = UIColor(red: 115/255.0, green: 127/255.0, blue: 154/255.0, alpha: 1.0)   // #7E7F9A
        static let BounceGrey = UIColor(red: 151/255.0, green: 167/255.0, blue: 179/255.0, alpha: 1.0)   // #97A7B3
    }
    
    struct Fonts {
        struct Avenir {
            static let Large = UIFont(name: "AvenirNext-Medium", size: 26)
            static let Medium = UIFont(name: "AvenirNext-Regular", size: 18)
            static let Small = UIFont(name: "AvenirNext-Regular", size: 14)
            static let Tiny = UIFont(name: "AvenirNext-Regular", size: 12)
        }
    }
}
