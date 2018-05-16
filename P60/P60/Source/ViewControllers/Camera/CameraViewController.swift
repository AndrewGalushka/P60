//
//  CameraViewController.swift
//  P60
//
//  Created by galushka on 5/10/18.
//  Copyright © 2018 AndrewGalushka. All rights reserved.
//

import UIKit
import AVFoundation

enum CameraPosition {
    case front
    case rear
}

class CameraViewController: BaseViewController {
    
    
    @IBOutlet weak var previewLayerContainerView: UIView!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    var currentCameraPosition: CameraPosition?
    var frontCamera: AVCaptureDevice?
    var rearCamera: AVCaptureDevice?

    var rearCameraInput: AVCaptureDeviceInput?
    var frontCameraInput: AVCaptureDeviceInput?
    
    var photoOutput: AVCapturePhotoOutput?

    var previewLayer: AVCaptureVideoPreviewLayer?
    
    init() {
        super.init(nibName: CameraViewController.identifier, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.previewLayerContainerView.layer.borderWidth = 3
        self.previewLayerContainerView.layer.borderColor = UIColor.randomColor.cgColor
        
        prepareCamera()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        displayPreview()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.previewLayer?.frame = self.previewLayerContainerView.bounds
    }
    
    func displayPreview() {
        
        guard
            let captureSession = self.captureSession,
            captureSession.isRunning
        else {
            return
        }
        
        if previewLayer != nil {
            previewLayer?.removeFromSuperlayer()
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        guard let previewLayer = self.previewLayer else { return }
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        
        self.previewLayerContainerView.layer.insertSublayer(previewLayer, at: 0)
        previewLayer.frame = self.previewLayerContainerView.bounds
    }
    
    @IBAction func backButtonTouchUpInsideActionHandler(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension CameraViewController {
    
    func prepareCamera() {
        
        DispatchQueue(label: "CameraViewController.prepareCamera").async {
            do {
                
                self.createCaptureSession()
                self.configureCaptureDevices()
                try self.configureDeviceInputs()
                try self.configurePhotoOutput()
                
            } catch {
                print("error")
            }
        }
    }
    
    func createCaptureSession() {
        self.captureSession = AVCaptureSession()
    }
    
    func configureCaptureDevices() {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                mediaType: AVMediaType.video,
                                                                position: AVCaptureDevice.Position.unspecified)
        
        let cameras = discoverySession.devices
        
        for camera in cameras {
            
            if camera.position == .front {
                
                self.frontCamera = camera
                
            } else if camera.position == .back {
                
                self.rearCamera = camera
                
                do {
                    
//                    try camera.unlockForConfiguration()
//                    camera.focusMode = .continuousAutoFocus
//                    try camera.lockForConfiguration()
                    
                } catch {
                    return
                }
            }
        }
    }
    
    func configureDeviceInputs() throws {
        
        guard let captureSession = self.captureSession else {
            return
        }
        
        if let rearCamera = self.rearCamera {
            
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            
            if let rearCameraInput = self.rearCameraInput {
                
                if captureSession.canAddInput(rearCameraInput) {
                    captureSession.addInput(rearCameraInput)
                    
                    self.currentCameraPosition = .rear
                }
            }
            
        } else if let frontCamera = self.frontCamera {
            
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            
            if let frontCameraInput = self.frontCameraInput {
                
                if captureSession.canAddInput(frontCameraInput) {
                    captureSession.addInput(frontCameraInput)
                }
                
                self.currentCameraPosition = .front
            }
            
        }
    }
    
    func configurePhotoOutput() throws {
        
        guard let captureSession = self.captureSession else {
            return
        }
        
        self.photoOutput = AVCapturePhotoOutput()
        let settings = AVCapturePhotoSettings()
        settings.livePhotoVideoCodecType = .jpeg
    
        if let photoOutput = self.photoOutput,
            captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
            
            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
         captureSession?.startRunning()
    }
}

extension CameraViewController: Identifiable {}
