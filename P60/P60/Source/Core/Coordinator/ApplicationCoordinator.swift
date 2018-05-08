//
//  ApplicationCoordinator.swift
//  P60
//
//  Created by galushka on 5/8/18.
//  Copyright © 2018 AndrewGalushka. All rights reserved.
//

import UIKit


class ApplicationCoordinator: Coordinator {

    let window: UIWindow
    let rootViewController: BaseTabBarController

    init(window: UIWindow) {
        self.window = window

        rootViewController = BaseTabBarController()
    }

    func start() {

        let mainStoryBoard = UIStoryboard.init(.main)

        let mainContentViewController: MainContentViewController = mainStoryBoard.instantiateViewController()
        let settingsViewController: SettingsViewController = mainStoryBoard.instantiateViewController()

        let mainContentViewControllerTabBarItem = UITabBarItem(title: nil, image: UIImage(named: "TabBarCameraIcon"), selectedImage: nil)
        let settingsViewControllerTabBarItem = UITabBarItem(title: nil, image: UIImage(named: "TabBarSettingsIcon"), selectedImage: nil)
        
        mainContentViewController.tabBarItem = mainContentViewControllerTabBarItem
        settingsViewController.tabBarItem = settingsViewControllerTabBarItem

        rootViewController.viewControllers = [mainContentViewController, settingsViewController]

        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
}
