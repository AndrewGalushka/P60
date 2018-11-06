//
//  CameraViewController.swift
//  P60
//
//  Created by galushka on 5/10/18.
//  Copyright © 2018 AndrewGalushka. All rights reserved.
//

import UIKit
import AVFoundation


class CameraViewController: BaseViewController {
    
    @IBOutlet weak var previewLayerContainerView: UIView!
    
    @IBOutlet weak var flashlightButton: UIButton!
    
    @IBOutlet weak var takePhotoButton: UIButton!
    
    
    @IBOutlet weak var bottomInterfaceVisualEffectView: UIVisualEffectView!
    @IBOutlet weak var topInterfaceVisualEffectView: UIVisualEffectView!
    
    let camera = Camera()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomInterfaceVisualEffectView.layer.cornerRadius = 20.0
        topInterfaceVisualEffectView.layer.cornerRadius = 20.0
        
        setupCamera()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        camera.previewLayer?.frame = previewLayerContainerView.bounds
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    // MARK: - Methods(Private)
    
    private func setupCamera() {
        DispatchQueue.global().async { [weak self] in
            guard let storngSelf = self else { return }
            storngSelf.camera.delegate = self
            storngSelf.camera.prepare()
            storngSelf.camera.run(on: storngSelf.previewLayerContainerView)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func backButtonTouchUpInsideActionHandler(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func switchCameraButtonTouchUpInside(_ sender: Any) {        
        self.camera.switchCamera()
    }
    
    var isFlashlightOn = false
    
    @IBAction func flashlightButtonTouchUpInsideActionHandler(_ sender: Any) {
        
        if isFlashlightOn {
            camera.torch(level: 0.0)
        } else {
            camera.torch(level: 1.0)
        }
        
        isFlashlightOn = !isFlashlightOn
    }
    
    @IBAction func takePhotoButtonTouchUpInside(_ sender: Any) {
        
        camera.takePhoto { [weak self] (capturedPhoto) in
            self?.openImagePreview(with: capturedPhoto)
        }
    }
    
    private func openImagePreview(with image: UIImage?) {
        let cameraVC = UIStoryboard.init(name: "Camera", bundle: nil).instantiateViewController(withIdentifier: TakenPhotoPreviewViewController.identifier) as! TakenPhotoPreviewViewController
        cameraVC.photo = image
        present(cameraVC, animated: true, completion: nil)
    }
}


extension CameraViewController: CameraDelegate {
    
    func camera(_: Camera, didChangedPosition position: CameraPosition) {
        
        switch position {
        case .front:
            self.flashlightButton.isHidden = false
        case .rear:
            self.flashlightButton.isHidden = true
        }
    }
}

extension CameraViewController: Identifiable {}
