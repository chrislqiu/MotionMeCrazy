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
import CoreGraphics
import CoreVideo
import SwiftUI
import TensorFlowLite
import UIKit

struct ViewControllerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ViewController {
        let vc = ViewController()
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
}

class ViewController: UIViewController {
    @IBOutlet private var previewLayer: AVCaptureVideoPreviewLayer!
    @IBOutlet private var overlayView: OverlayView!
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

        overlayView = OverlayView(frame: view.bounds)
        overlayView.backgroundColor = .clear // Ensure transparency
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // Resizes correctly
        view.addSubview(overlayView)
    }

    private func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: videoCapture.captureSession)
        previewLayer.videoGravity = .resizeAspect  // Ensures proper scaling without squishing
        previewLayer.frame = view.layer.bounds
        previewLayer.contentsScale = UIScreen.main.scale // Ensures sharp rendering
 
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
        if let pixelBuffer = convertCGImageToPixelBuffer(image) {
            poseNetModel.estimatePose(from: pixelBuffer) { result in
                DispatchQueue.main.async {
                    let uiImage = UIImage(cgImage: image)
                    print(result)
                    if let firstPerson = result.first {
                        self.overlayView.draw(at: uiImage, person: firstPerson)
                    } else {
                        print("No person detected in the frame.")
                    }
                    self.currentFrame = nil
                }
            }
        } else {
            currentFrame = nil
        }
    }
}
