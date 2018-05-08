//
// Created by galushka on 5/8/18.
// Copyright (c) 2018 AndrewGalushka. All rights reserved.
//

import UIKit


extension UIStoryboard {
    enum Storyboard: String {
        case main

        var filename: String {
            return rawValue.capitalized
        }
    }

    convenience init(_ storyboard: Storyboard) {
        self.init(name: storyboard.filename, bundle: nil)
    }

    func instantiateViewController<T>() -> T where T: UIViewController & Identifiable {

        guard let viewController = instantiateViewController(withIdentifier: T.identifier) as? T else {
            fatalError("Couldn't load viewController with \(T.identifier) identifier")
        }

        return viewController
    }
}

