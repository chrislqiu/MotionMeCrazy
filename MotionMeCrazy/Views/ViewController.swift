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
    //@IBOutlet private var previewLayer: AVCaptureVideoPreviewLayer!
    @IBOutlet private var overlayView: OverlayView!
    private var videoCapture: VideoCapture!
    private var model: MoveNet!
    private var currentFrame: CGImage?
    var isRunning = false
    
    let queue = DispatchQueue(label: "serial_queue")
    let minimumScore: Float32 = 0.3

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideoCapture()
        setupModel()
    }

    private func setupVideoCapture() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.setUpAVCapture { error in
            if let error = error {
                print("Failed to setup camera with error \(error)")
                return
            }

            //self.setupPreviewLayer()
            self.videoCapture.startCapturing()
        }

        overlayView = OverlayView(frame: view.bounds)
        overlayView.backgroundColor = .clear // Ensure transparency
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // Resizes correctly
        view.addSubview(overlayView)
    }

//    private func setupPreviewLayer() {
//        previewLayer = AVCaptureVideoPreviewLayer(session: videoCapture.captureSession)
//        previewLayer.videoGravity = .resizeAspect  // Ensures proper scaling without squishing
//        previewLayer.frame = view.layer.bounds
//        previewLayer.contentsScale = UIScreen.main.scale // Ensures sharp rendering
// 
//        view.layer.insertSublayer(previewLayer, at: 0)
//    }

    private func setupModel() {
        queue.async {
            do {
                self.model = try MoveNet(threadCount: 4, delegate: .gpu, modelType: .movenetLighting)
            } catch let error {
                print(error)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        videoCapture.stopCapturing {
            super.viewWillDisappear(animated)
        }
    }
}

// MARK: - VideoCaptureDelegate
extension ViewController: VideoCaptureDelegate {
    func videoCapture(_ videoCapture: VideoCapture, didOutput pixelBuffer: CVPixelBuffer) {
        guard !isRunning else { return }
        
        guard let estimator = model else { return }

        // Run inference on a serial queue to avoid race condition.
        queue.async {
            self.isRunning = true
            defer { self.isRunning = false }

            // Run pose estimation
            do {
                let result = try estimator.estimateSinglePose(on: pixelBuffer)

                // Return to main thread to show detection results on the app UI.
                DispatchQueue.main.async {
                    print(result.score)

                    // Allowed to set image and overlay
                    let image = UIImage(ciImage: CIImage(cvPixelBuffer: pixelBuffer))

                    // If score is too low, clear result remaining in the overlayView.
                    if result.score < self.minimumScore {
                        self.overlayView.image = image
                        return
                    }

                    self.overlayView.draw(at: image, person: result)
                }
            } catch {
                print("Error running pose estimation.")
                return
            }
        }
    }
}
