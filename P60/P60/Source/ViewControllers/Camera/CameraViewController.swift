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
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    var currentCameraPosition: CameraPosition?
    var frontCamera: AVCaptureDevice?
    var rearCamera: AVCaptureDevice?

    var rearCameraInput: AVCaptureDeviceInput?
    var frontCameraInput: AVCaptureDeviceInput?

    init() {
        super.init(nibName: CameraViewController.identifier, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareCamera()
    }

    func prepareCamera() {
        createCaptureSession()
        configureCaptureDevices()
        configureDeviceInputs()
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

                    try camera.unlockForConfiguration()
                    camera.focusMode = .continuousAutoFocus
                    try camera.lockForConfiguration()

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
}

extension CameraViewController: Identifiable {}
