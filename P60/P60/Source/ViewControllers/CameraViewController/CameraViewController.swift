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
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    @IBOutlet weak var previewLayerContainerView: UIView!

    let camera = Camera()

    init() {
        super.init(nibName: CameraViewController.identifier, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        camera.prepare()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setVisualEffect(shown: true, animated: true, duration: 0.25)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        camera.run(on: previewLayerContainerView)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) { [weak self] in
            self?.setVisualEffect(shown: false, animated: animated)
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setVisualEffect(shown isShown: Bool, animated: Bool, duration: TimeInterval = 0.25 ) {
        
        let animationDuration = animated ? duration : 0.0
        
        func showVisualEffect() {
            
            guard let visualEffectView = self.visualEffectView else {
                return
            }
        
            self.visualEffectView.alpha = 1.0
            
            UIView.animate(withDuration: animationDuration, animations: {
                visualEffectView.effect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
            },  completion: { (finished) in
            })
        }
        
        func hideVisualEffect() {
            
            guard let visualEffectView = self.visualEffectView else {
                return
            }
            
            UIView.animate(withDuration: animationDuration, animations: {
                visualEffectView.effect = nil
            }, completion: { (finished) in
                visualEffectView.alpha = 0.0
            })
        }
        
        if isShown {
            showVisualEffect()
        } else {
            hideVisualEffect()
        }
     }

    @IBAction func backButtonTouchUpInsideActionHandler(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func switchCameraButtonTouchUpInside(_ sender: Any) {

        guard let previewLayerContainerView = self.previewLayerContainerView else {
            return
        }
        
        UIView.transition(with: previewLayerContainerView, duration: 0.25, options: [.transitionFlipFromLeft, .allowAnimatedContent], animations: {
            self.camera.switchCamera()
            self.setVisualEffect(shown: true, animated: true)
        }) { (finished) in
            self.setVisualEffect(shown: false, animated: true)
        }
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
    
    
    
}


extension CameraViewController: Identifiable {}
