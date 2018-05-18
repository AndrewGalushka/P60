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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        displayVisualEffectView()
        
        camera.run(on: previewLayerContainerView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.hideVisualEffectView()
        }
    }

    @IBAction func backButtonTouchUpInsideActionHandler(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    func displayVisualEffectView() {

        if visualEffectView != nil {
            visualEffectView?.removeFromSuperview()
        }

        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualEffectView?.frame = view.bounds

        if let visualEffectView = visualEffectView {
            view.addSubview(visualEffectView)
        }
    }

    func hideVisualEffectView() {

        if let visualEffectView = visualEffectView {

            UIView.animate(withDuration: 2.0, animations: {
                visualEffectView.effect = nil
            }) { (finished) in
                visualEffectView.removeFromSuperview()
            }
        }
    }
    
}


extension CameraViewController: Identifiable {}
