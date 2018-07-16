//
//  CameraController.swift
//  InstagramFirebase
//
//  Created by Allan Araujo on 6/25/18.
//  Copyright © 2018 Escher. All rights reserved.
//

import UIKit
import AVFoundation

//Make sure to add into INFO.PLIST
class CameraController: UIViewController, AVCapturePhotoCaptureDelegate, UIViewControllerTransitioningDelegate {
    let output = AVCapturePhotoOutput()
    let customAnimationPresenter = CustomAnimationPresenter()
    let customAnimationDismisser = CustomAnimationDismisser()
    
    let capturePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "capture_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCapturePhoto), for: .touchUpInside)
        return button
    }()
    
    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "right_arrow_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transitioningDelegate = self
        
        setupCaptureSession()
        setupButtons()
    }
    
    fileprivate func setupButtons() {
        view.addSubview(capturePhotoButton)
        capturePhotoButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 24, paddingRight: 0, width: 80, height: 80)
        capturePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(dismissButton)
        dismissButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 50)
    }

    @objc func handleCapturePhoto() {
        print("capturing photo")
        let settings = AVCapturePhotoSettings()
        
        guard let previewFormatType = settings.availablePreviewPhotoPixelFormatTypes.first else {
            print("unable to get first preview format type")
            return
        }
        settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewFormatType]
        
        output.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("failed to conved pixel buffer")
            return
        }
        let previewImage = UIImage(data: imageData)
        
        let containerView = PreviewPhotoContainerView()
        containerView.previewImageView.image = previewImage
        
        view.addSubview(containerView)
        containerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        print("Finishing processing photo sample buffer...")
    }

    
    fileprivate func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        
        //1. Setup inputs
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            //Required as a safeguard to see if input can actually be used. 
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
        } catch let err {
            print("Could not setup camera input: ", err)
        }
    
        //2. Setup outputs
        if captureSession.canAddOutput(output){
            captureSession.addOutput(output)
        }

        //3. Setup output preview
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func handleDismiss() {
        print("dismiss camera")
        dismiss(animated: true, completion: nil)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationPresenter
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationDismisser
    }
    
}



