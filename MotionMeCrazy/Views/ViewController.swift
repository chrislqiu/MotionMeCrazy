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

struct Pose {
    var joints: [(x: CGFloat, y: CGFloat)]
}

struct CameraPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> PreviewView {
        let preview = PreviewView()
        return preview
    }
    
    func updateUIView(_ previewView: PreviewView, context: Context) { }
}

class PreviewView: UIView {
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
    @IBOutlet private var previewView: PreviewView!
    @IBOutlet private var overlayView: PoseOverlayView!

    private let videoCapture = VideoCapture()

    //TODO: add PoseNet Model
    //private var poseNet: PoseNet!

    //TODO: might change to pixelbuffer
    /// The frame the PoseNet model is currently making pose predictions from.
    private var currentFrame: CGImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        // For convenience, the idle timer is disabled to prevent the screen from locking.
        UIApplication.shared.isIdleTimerDisabled = true

        setupAndBeginCapturingVideoFrames()
        //TODO: set up PoseNet model
        // do {
        //     poseNet = try PoseNet()
        // } catch {
        //     fatalError("Failed to load model. \(error.localizedDescription)")
        // }

        // poseNet.delegate = self
    }

    private func setupAndBeginCapturingVideoFrames() {
        videoCapture.setUpAVCapture { error in
            if let error = error {
                print("Failed to setup camera with error \(error)")
                return
            }

            self.videoCapture.delegate = self

            previewView.setSession(self.videoCapture.captureSession)
            previewView.previewLayer.videoGravity = .resizeAspectFill
            previewView.previewLayer.frame = view.layer.bounds
            view.layer.addSublayer(previewView.previewLayer)
            
            overlayView = PoseOverlayView(frame: view.bounds)
            view.addSubview(overlayView)

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
