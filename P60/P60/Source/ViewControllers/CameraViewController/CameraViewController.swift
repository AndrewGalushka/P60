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

    let camera = Camera()

    var visualEffectView: UIVisualEffectView?

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
        
        setVisualEffect(shown: true, animated: true)
    }
    
//    override func viewWillLayoutSubviews() {
//        <#code#>
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        camera.run(on: previewLayerContainerView)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [weak self] in
            self?.setVisualEffect(shown: false, animated: animated)
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setVisualEffect(shown isShown: Bool, animated: Bool, duration: TimeInterval = 0.25 ) {
        
        let animationDuration = animated ? duration : 0.0
        
        func showVisualEffect() {
            
            if visualEffectView != nil {
                visualEffectView?.removeFromSuperview()
            }
            
            visualEffectView = UIVisualEffectView()
            
            guard let visualEffectView = self.visualEffectView else {
                return
            }
            
            visualEffectView.frame = view.bounds
            visualEffectView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]

            view.addSubview(visualEffectView)
            
            UIView.animate(withDuration: animationDuration, animations: {
                visualEffectView.effect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
            }, completion: nil)
        }
        
        func hideVisualEffect() {
            
            guard let visualEffectView = self.visualEffectView else {
                return
            }
            
            UIView.animate(withDuration: animationDuration, animations: {
                visualEffectView.effect = nil
            }, completion: { (finished) in
                visualEffectView.removeFromSuperview()
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
        
        UIView.transition(with: previewLayerContainerView, duration: 0.25, options: UIViewAnimationOptions.transitionFlipFromLeft, animations:nil, completion: nil)
        self.camera.switchCamera(withDelay: 0.2)
        
    }
    
}


extension CameraViewController: Identifiable {}
