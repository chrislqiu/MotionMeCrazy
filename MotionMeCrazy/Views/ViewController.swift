//
//  ViewController.swift
//  MotionMeCrazy
//
//  Created by Elasia Rodriguez on 2/20/25.
//

/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The implementation of the application's view controller, responsible for coordinating
 the user interface, video feed, and PoseNet model.
*/

import AVFoundation
import CoreImage
import SwiftUI
import TensorFlowLite
import UIKit
import VideoToolbox

struct Pose {
    var joints: [(x: CGFloat, y: CGFloat)]
}

struct ViewControllerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ViewController {
        let vc = ViewController()
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
}

class PoseOverlayView: UIView {
    private var poses: [Pose] = []
    
    func update(with poses: [Pose]) {
        self.poses = poses
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        for pose in poses {
            for joint in pose.joints {
                let point = CGPoint(x: joint.x * bounds.width, y: joint.y * bounds.height)
                context.setFillColor(UIColor.red.cgColor)
                context.fillEllipse(in: CGRect(x: point.x - 5, y: point.y - 5, width: 10, height: 10))
            }
        }
    }
}

class ViewController: UIViewController {
    @IBOutlet private var previewLayer: AVCaptureVideoPreviewLayer!
    @IBOutlet private var overlayView: PoseOverlayView!
    private var videoCapture: VideoCapture!
    private var poseNetModel: PoseNetModel!
    private var currentFrame: CGImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideoCapture()
        setupPoseNetModel()
    }

    private func setupVideoCapture() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.setUpAVCapture { error in
            if let error = error {
                print("Failed to setup camera with error \(error)")
                return
            }

            self.setupPreviewLayer()
            self.videoCapture.startCapturing()
        }

        overlayView = PoseOverlayView(frame: view.bounds)
        view.addSubview(overlayView)
    }

    private func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: videoCapture.captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
    }

    private func setupPoseNetModel() {
        poseNetModel = PoseNetModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        videoCapture.stopCapturing {
            super.viewWillDisappear(animated)
        }
    }

    func convertCGImageToPixelBuffer(_ image: CGImage) -> CVPixelBuffer? {
        let width = image.width
        let height = image.height

        var pixelBuffer: CVPixelBuffer?
        let attributes: [CFString: Any] = [
            kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey: width,
            kCVPixelBufferHeightKey: height,
            kCVPixelBufferBytesPerRowAlignmentKey: width * 4,
            kCVPixelBufferIOSurfacePropertiesKey: [:]
        ]

        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                        kCVPixelFormatType_32BGRA,
                                        attributes as CFDictionary,
                                        &pixelBuffer)

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            print("Failed to create pixel buffer")
            return nil
        }

        CVPixelBufferLockBaseAddress(buffer, [])
        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        ) else {
            print("Failed to create CGContext")
            CVPixelBufferUnlockBaseAddress(buffer, [])
            return nil
        }

        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        CVPixelBufferUnlockBaseAddress(buffer, [])

        return buffer
    }
}

// MARK: - VideoCaptureDelegate
extension ViewController: VideoCaptureDelegate {
    func videoCapture(_ videoCapture: VideoCapture, didCaptureFrame capturedImage: CGImage?) {
        guard currentFrame == nil else {
            return
        }
        guard let image = capturedImage else {
            fatalError("Captured image is null")
        }

        currentFrame = image
        if let pixelBuffer = convertCGImageToPixelBuffer(currentFrame) {
            poseNetModel.estimatePoses(from: pixelBuffer) { poses in
                DispatchQueue.main.async {
                    self.overlayView.update(with: poses)
                }
            }
        }
    }
}

class PoseNetModel {
    private var interpreter: Interpreter!
    
    init() {
        guard let modelPath = Bundle.main.path(forResource: "posenet_mobilenet_v1_100_257x257_multi_kpt_stripped", ofType: "tflite") else { return }
        interpreter = try? Interpreter(modelPath: modelPath)
    }
    
    func estimatePoses(from pixelBuffer: CVPixelBuffer, completion: @escaping ([Pose]) -> Void) {
        guard let resizedBuffer = pixelBuffer.resize(to: CGSize(width: 257, height: 257)) else { return }
        
        do {
            try interpreter.allocateTensors()
            
            let inputTensor = try interpreter.input(at: 0)
            let inputData = convertToTensorData(pixelBuffer: resizedBuffer, tensor: inputTensor)
            
            try interpreter.copy(inputData, toInputAt: 0)
            try interpreter.invoke()
            
            let outputTensor = try interpreter.output(at: 0)
            let outputData = [Float](unsafeData: outputTensor.data)
            
            let poses = parsePoseData(outputData)
            completion(poses)
        } catch {
            print("Error running inference: \(error)")
            completion([])
        }
    }
}
