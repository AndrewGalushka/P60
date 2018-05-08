//
//  Identifiable.swift
//  P60
//
//  Created by galushka on 5/8/18.
//  Copyright © 2018 AndrewGalushka. All rights reserved.
//

import Foundation


protocol Identifiable: class {
    static var identifier: String { get }
}

extension Identifiable {
    static var identifier: String {
        return String(describing: self)
    }
}
