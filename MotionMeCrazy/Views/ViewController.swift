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
import UIKit
import VideoToolbox

struct CameraPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> PreviewView {
        let preview = PreviewView()
        return preview
    }
    
    func updateUIView(_ previewView: PreviewView, context: Context) { }
}

class PreviewView: UIView, PreviewTarget {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
    
    func setSession(_ session: AVCaptureSession) {
        previewLayer.session = session
    }
}

class ViewController: UIViewController {
    @IBOutlet private var previewView: PreviewView!
    //TODO
    //@IBOutlet private var poseNetView: PoseNetView!

    private let videoCapture = VideoCapture()

    //TODO
    //private var poseNet: PoseNet!

    /// The frame the PoseNet model is currently making pose predictions from.
    private var currentFrame: CGImage?

    /// The algorithm the controller uses to extract poses from the current frame.
    private var algorithm: Algorithm = .single

    override func viewDidLoad() {
        super.viewDidLoad()

        // For convenience, the idle timer is disabled to prevent the screen from locking.
        UIApplication.shared.isIdleTimerDisabled = true

        //TODO
        // do {
        //     poseNet = try PoseNet()
        // } catch {
        //     fatalError("Failed to load model. \(error.localizedDescription)")
        // }

        // poseNet.delegate = self
        setupAndBeginCapturingVideoFrames()
    }

    private func setupAndBeginCapturingVideoFrames() {
        videoCapture.setUpAVCapture { error in
            if let error = error {
                print("Failed to setup camera with error \(error)")
                return
            }

            self.videoCapture.delegate = self

            previewView.setSession(self.videoCapture.captureSession)

            self.videoCapture.startCapturing()
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
    func videoCapture(_ videoCapture: VideoCapture, didCaptureFrame capturedImage: CGImage?) {
        guard currentFrame == nil else {
            return
        }
        guard let image = capturedImage else {
            fatalError("Captured image is null")
        }

        currentFrame = image
        //TODO
        //poseNet.predict(image)
    }
}

// MARK: - PoseNetDelegate

//TODO
// extension ViewController: PoseNetDelegate {
//     func poseNet(_ poseNet: PoseNet, didPredict predictions: PoseNetOutput) {
//         defer {
//             // Release `currentFrame` when exiting this method.
//             self.currentFrame = nil
//         }

//         guard let currentFrame = currentFrame else {
//             return
//         }

//         let poseBuilder = PoseBuilder(output: predictions,
//                                       configuration: poseBuilderConfiguration,
//                                       inputImage: currentFrame)

//         let poses = algorithm == .single
//             ? [poseBuilder.pose]
//             : poseBuilder.poses

//         previewImageView.show(poses: poses, on: currentFrame)
//     }
// }
