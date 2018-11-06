//
//  Camera.swift
//  P60
//
//  Created by galushka on 5/16/18.
//  Copyright © 2018 AndrewGalushka. All rights reserved.
//

import UIKit
import AVFoundation

enum CameraError: Error {
    case captureDeviceInputInitializationError
}

enum CameraPosition {
    case front
    case rear
}

class Camera: NSObject {
    
    private var captureSession: AVCaptureSession?
    
    private var frontCameraDevice: AVCaptureDevice?
    private var rearCameraDevice: AVCaptureDevice?
    private var microphone: AVCaptureDevice?

    private var frontCameraDeviceInput: AVCaptureDeviceInput?
    private var rearCameraDeviceInput: AVCaptureDeviceInput?

    private var photoOutput: AVCapturePhotoOutput?
    private(set) var previewLayer: AVCaptureVideoPreviewLayer?
    
    private var isTakePhoto = false
    private var takePhotoCompletionHandler: ((_: UIImage?) -> Void)?
    
    var cameraPosition: CameraPosition? {
        
        didSet {
            if let position = oldValue {
                self.delegate?.camera(self, didChangedPosition: position)
            }
        }
    }
    
    var delegate: CameraDelegate?
    
    func prepare() {
        createCaptureSession()
        configureDevices()
        configureInputs()
        
        if canConnectRearCamera() {
            
            if let rearCameraDeviceInput = rearCameraDeviceInput {
                connectDeviceInput(rearCameraDeviceInput)
                cameraPosition = .rear
            }

        } else if canConnectFrontCamera() {
            
            if let frontCameraDeviceInput = frontCameraDeviceInput {
                connectDeviceInput(frontCameraDeviceInput)
                cameraPosition = .front
            }
        }
        
        configureOutput()
        
        self.captureSession?.startRunning()
    }
    
    func run(on view: UIView) {
        
        guard
            let captureSession = captureSession
        else {
            return
        }
        
        let isMainThread = Thread.isMainThread
        
        if self.previewLayer != nil {
            
            if isMainThread {
                self.previewLayer?.removeFromSuperlayer()
            } else {
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.previewLayer?.removeFromSuperlayer()
                }
            }
            
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        if (isMainThread) {
            previewLayer.frame = view.bounds
            self.previewLayer = previewLayer
            view.layer.addSublayer(previewLayer)
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                previewLayer.frame = view.bounds
                strongSelf.previewLayer = previewLayer
                view.layer.addSublayer(previewLayer)
            }
        }
    }

    func torch(level: Float) {
        
        guard let cameraPosition = self.cameraPosition else {
            return
        }
        
        let currentCameraDevice: AVCaptureDevice
        
        switch cameraPosition {
        case .front:
            guard let frontCamera = self.frontCameraDevice else {
                return
            }
            
            currentCameraDevice = frontCamera
        case .rear:
            guard let backCamera = self.rearCameraDevice else {
                return
            }
            
            currentCameraDevice = backCamera
        }
        
        if currentCameraDevice.hasTorch {
            
            if let _ = try? currentCameraDevice.lockForConfiguration() {
                
                if (level <= 0.0) {
                    currentCameraDevice.torchMode = .off
                } else {
                    if let _ = try? currentCameraDevice.setTorchModeOn(level: Float.minimum(level, 1.0)) {}
                }
            }
        }
    }
    
    func switchCamera() {

        guard
            let captureSession = captureSession,
            let cameraPosition = cameraPosition,
            let frontCameraInput = frontCameraDeviceInput,
            let backCameraInput = rearCameraDeviceInput
        else {
                return
        }

        let currentDeviceInput: AVCaptureDeviceInput
        let newDeviceInput: AVCaptureDeviceInput
        
        switch cameraPosition {
        case .front:
            currentDeviceInput = frontCameraInput
            newDeviceInput = backCameraInput
            self.cameraPosition = .rear
        case .rear:
            currentDeviceInput = backCameraInput
            newDeviceInput = frontCameraInput
            self.cameraPosition = .front
        }
        
        captureSession.removeInput(currentDeviceInput)

        if captureSession.canAddInput(newDeviceInput) {
            captureSession.addInput(newDeviceInput)
        }
    }
    
    func switchCamera(withDelay delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
            self.switchCamera()
        }
    }
    
    func canSwitchCamera() -> Bool {
        
        guard
            let _ = captureSession,
            let _ = cameraPosition,
            let _ = frontCameraDeviceInput,
            let _ = rearCameraDeviceInput
        else {
                return false
        }
    
        return true
    }
    
    func takePhoto(copletionHandler: @escaping (_: UIImage?) -> Void) {
        self.takePhotoCompletionHandler = copletionHandler
        self.isTakePhoto = true
        
        self.photoOutput?.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
}

extension Camera {
    private func createCaptureSession() {
        captureSession = AVCaptureSession()
    }

    private func configureDevices() {

        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInMicrophone],
                                                                  mediaType: .video,
                                                                   position: .unspecified)

        let devices = discoverySession.devices

        var microphone: AVCaptureDevice?
        
        var rearDualCamera: AVCaptureDevice?
        var rearWideAngleCamera: AVCaptureDevice?
        
        var frontDualCamera: AVCaptureDevice?
        var frontWideAngleCamera: AVCaptureDevice?

        for device in devices {

            switch device.deviceType {
            case AVCaptureDevice.DeviceType.builtInDualCamera:
                
                switch device.position {
                case .back:
                    rearDualCamera = device
                case .front:
                    frontDualCamera = device
                case .unspecified:
                    break
                }
                
            case AVCaptureDevice.DeviceType.builtInMicrophone:
                microphone = device
            case AVCaptureDevice.DeviceType.builtInWideAngleCamera:
                
                switch device.position {
                case .back:
                    rearWideAngleCamera = device
                case .front:
                    frontWideAngleCamera = device
                case .unspecified:
                    break
                }
       
            case AVCaptureDevice.DeviceType.builtInTrueDepthCamera:
                break
            default:
                break
            }
        }
        
        var frontCamera: AVCaptureDevice?
        var rearCamera: AVCaptureDevice?
        
        if let rearDualCamera = rearDualCamera {
            rearCamera = rearDualCamera
        } else if let rearWideAngleCamera = rearWideAngleCamera {
            rearCamera = rearWideAngleCamera
        }
        
        if let frontDualCamera = frontDualCamera {
            frontCamera = frontDualCamera
        } else if let frontWideAngleCamera = frontWideAngleCamera {
            frontCamera = frontWideAngleCamera
        }
        
        self.frontCameraDevice = frontCamera
        self.rearCameraDevice = rearCamera
        self.microphone = microphone
    }

    private func configureInputs() {

        if let frontCamera = frontCameraDevice,
           let frontCameraInput = try? AVCaptureDeviceInput(device: frontCamera) {

             self.frontCameraDeviceInput = frontCameraInput
        }

        if let rearCamera = rearCameraDevice,
           let rearCameraDeviceInput = try? AVCaptureDeviceInput(device: rearCamera) {

            self.rearCameraDeviceInput = rearCameraDeviceInput
        }
    }

    private func canConnectRearCamera() -> Bool {
        guard
            let captureSession = self.captureSession,
            let rearCameraInput = self.rearCameraDeviceInput,
            captureSession.canAddInput(rearCameraInput)
        else {
            return false
        }

        return true
    }

    private func canConnectFrontCamera() -> Bool {
        guard
            let captureSession = self.captureSession,
            let frontCameraInput = self.frontCameraDeviceInput,
            captureSession.canAddInput(frontCameraInput)
        else {
                return false
        }
        
        return true
    }

    private func connectDeviceInput(_ deviceInput: AVCaptureDeviceInput) {

        guard let captureSession = self.captureSession else {
            return
        }

        captureSession.addInput(deviceInput)
    }

    private func configureOutput() {

        guard let captureSession = captureSession else {
            return
        }
        
        self.photoOutput = AVCapturePhotoOutput()

        guard
            let capturePhotoOutput = self.photoOutput,
            captureSession.canAddOutput(capturePhotoOutput)
        else {
            return
        }
        
        captureSession.addOutput(capturePhotoOutput)
    }
}

extension Camera: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if isTakePhoto {
            
            if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData){
                
                self.takePhotoCompletionHandler?(image)
            }
        }
        
        isTakePhoto = false
    }
}

