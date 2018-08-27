//
//  TakenPhotoPreviewViewController.swift
//  P60
//
//  Created by galushka on 8/27/18.
//  Copyright © 2018 AndrewGalushka. All rights reserved.
//

import UIKit

class TakenPhotoPreviewViewController: BaseViewController {
    @IBOutlet weak var photoImageView: UIImageView!
    
    var photo: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        photoImageView.image = photo
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func backButtonTouchUpInsideActionHandler(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension TakenPhotoPreviewViewController: Identifiable {}
