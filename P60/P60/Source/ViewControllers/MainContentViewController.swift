//
//  MainContentViewController.swift
//  P60
//
//  Created by galushka on 3/24/18.
//  Copyright © 2018 AndrewGalushka. All rights reserved.
//

import UIKit

class MainContentViewController: BaseViewController{

    @IBOutlet weak var takePhotoButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func takePhotoButtonTouchUpInside(_ sender: Any) {
        let cameraVC = CameraViewController()
        present(cameraVC, animated: true, completion: nil)
    }
}

extension MainContentViewController {
    func setUpUI() {
        self.takePhotoButton.layer.borderColor = UIColor.gray.cgColor
        self.takePhotoButton.layer.borderWidth = 2.0
        self.takePhotoButton.layer.cornerRadius = 10.0
    }
}

extension MainContentViewController: Identifiable {}
