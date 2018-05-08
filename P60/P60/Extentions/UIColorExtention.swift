//
// Created by galushka on 5/8/18.
// Copyright (c) 2018 AndrewGalushka. All rights reserved.
//

import UIKit

extension UIColor {
    static var randomColor: UIColor {
        return UIColor(red: CGFloat(arc4random() % 255) / 255.0,
                green: CGFloat(arc4random() % 255) / 255.0,
                blue: CGFloat(arc4random() % 255) / 255.0,
                alpha: 1)
    }
}
