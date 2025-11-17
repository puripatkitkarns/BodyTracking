//
//  CameraView.swift
//  Body Tracking
//
//  Created by 677112 on 11/14/25.
//

import SwiftUI
import UIKit
import AVFoundation
import Vision

struct CameraView: UIViewControllerRepresentable {
    var onPoseDetected: (VNHumanBodyPoseObservation) -> Void
    
    func makeUIViewController(context: Context) -> CameraController {
        let controller = CameraController()
        controller.onPoseDetected = onPoseDetected
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraController, context: Context) {}
}

class CameraController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var session = AVCaptureSession()
    var onPoseDetected: ((VNHumanBodyPoseObservation) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    func setupCamera() {
        session.sessionPreset = .medium
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)!
        let input = try! AVCaptureDeviceInput(device: device)
        session.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraQueue"))
        session.addOutput(output)
        
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = view.bounds
        view.layer.addSublayer(preview)
        
        session.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let request = VNDetectHumanBodyPoseRequest { req, _ in
            guard let obs = req.results?.first as? VNHumanBodyPoseObservation else { return }
            self.onPoseDetected?(obs)
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .leftMirrored)
        try? handler.perform([request])
    }
}
