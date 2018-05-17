//
//  Camera.swift
//  P60
//
//  Created by galushka on 5/16/18.
//  Copyright © 2018 AndrewGalushka. All rights reserved.
//

import AVFoundation

enum CameraError: Error {
    case captureDeviceInputInitializationError
}

class Camera {
    
    var captureSession: AVCaptureSession?
    
    var frontCameraDevice: AVCaptureDevice?
    var rearCameraDevice: AVCaptureDevice?
    var microphone: AVCaptureDevice?

    var frontCameraDeviceInput: AVCaptureDeviceInput?
    var rearCameraDeviceInput: AVCaptureDeviceInput?

    func prepare() {
    }
}

extension Camera {
    func createCaptureSession() {
        captureSession = AVCaptureSession()
    }
    
    func configureDevices() {

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

    func configureInputs() {

        if let frontCamera = frontCameraDevice,
           let frontCameraInput = try? AVCaptureDeviceInput(device: frontCamera) {

             self.frontCameraDeviceInput = frontCameraInput
        }

        if let rearCamera = rearCameraDevice,
           let rearCameraDeviceInput = try? AVCaptureDeviceInput(device: rearCamera) {

            self.rearCameraDeviceInput = rearCameraDeviceInput
        }
    }

    func canConnectRearCamera() -> Bool {
        guard
            let captureSession = self.captureSession,
            let rearCameraInput = self.rearCameraDeviceInput,
            captureSession.canAddInput(rearCameraInput)
        else {
            return false
        }

        return true
    }
    
    func canConnectFrontCamera() -> Bool {
        guard
            let captureSession = self.captureSession,
            let frontCameraInput = self.frontCameraDeviceInput,
            captureSession.canAddInput(frontCameraInput)
        else {
                return false
        }
        
        return true
    }

}

