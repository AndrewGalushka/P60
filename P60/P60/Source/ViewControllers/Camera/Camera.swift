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

fileprivate enum CameraPosition {
    case front
    case rear
}

class Camera: NSObject {
    
    var captureSession: AVCaptureSession?
    
    var frontCameraDevice: AVCaptureDevice?
    var rearCameraDevice: AVCaptureDevice?
    var microphone: AVCaptureDevice?

    var frontCameraDeviceInput: AVCaptureDeviceInput?
    var rearCameraDeviceInput: AVCaptureDeviceInput?
    private var cameraPosition: CameraPosition?

    var photoOutput: AVCapturePhotoOutput?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
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
            let captureSession = captureSession,
            captureSession.isRunning
        else {
            return
        }
        
        if previewLayer != nil {
            previewLayer?.removeFromSuperlayer()
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.frame = view.bounds
        
        view.layer.addSublayer(previewLayer!)
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

        let capturePhotoSettings = AVCapturePhotoSettings()
        capturePhotoSettings.livePhotoVideoCodecType = .jpeg
//        capturePhotoSettings.isHighResolutionPhotoEnabled = true
        
        guard
            let capturePhotoOutput = self.photoOutput,
            captureSession.canAddOutput(capturePhotoOutput)
        else {
            return
        }
        
        captureSession.addOutput(capturePhotoOutput)
        self.photoOutput?.capturePhoto(with: capturePhotoSettings, delegate: self)
    }

}

extension Camera: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {

    }
}

