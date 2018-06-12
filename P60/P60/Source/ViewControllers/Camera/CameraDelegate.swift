//
//  CameraDelegate.swift
//  P60
//
//  Created by galushka on 6/12/18.
//  Copyright © 2018 AndrewGalushka. All rights reserved.
//

import Foundation

protocol CameraDelegate {
    func camera(_: Camera, didChangedPosition position: CameraPosition)
}

extension CameraDelegate {
    func camera(_: Camera, didChangedPosition position: CameraPosition) {}
}
