//
//  AppDelegate.swift
//  P60
//
//  Created by galushka on 3/24/18.
//  Copyright © 2018 AndrewGalushka. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var applicationCoordinator: Coordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        guard let window = window else {
            fatalError("Window cannot be nil")
        }

        applicationCoordinator = ApplicationCoordinator(window: window)
        applicationCoordinator?.start()

        return true
    }

}

