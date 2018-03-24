//
//  MainContentViewController.swift
//  P60
//
//  Created by galushka on 3/24/18.
//  Copyright © 2018 AndrewGalushka. All rights reserved.
//

import UIKit
import QuartzCore

class MainContentViewController: BaseViewController {
    
    @IBOutlet weak var takePhotoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func takePhotoButtonTouchUpInsideActionHander(_ sender: Any) {
    }
}

extension MainContentViewController {
    func setUpUI() {
        self.takePhotoButton.layer.borderColor = UIColor.black.cgColor
    }
}