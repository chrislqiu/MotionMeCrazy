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
import CoreImage.CIFilterBuiltins
import CoreGraphics
import CoreVideo
import SwiftUI
import TensorFlowLite
import UIKit

struct ViewControllerView: UIViewControllerRepresentable {
    @Binding var obstacleImageName: String!
    
    func makeUIViewController(context: Context) -> ViewController {
        let vc = ViewController()
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        guard obstacleImageName != nil else { return }
        uiViewController.detectCollisions(imageName: obstacleImageName)
    }
}

class ViewController: UIViewController {
    @IBOutlet private var previewLayer: AVCaptureVideoPreviewLayer!
    @IBOutlet private var overlayView: OverlayView!
    private var videoCapture: VideoCapture!
    private var model: MoveNet!
    var skeleton: [KeyPoint]?
    var collisionPoints: [CGPoint] = []
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

    func detectCollisions(imageName: String) {
        guard let keypoints = skeleton else { return }
        
        guard let obstacleImage = UIImage(named: imageName)!.cgImage else { return }
        guard let pixelData = getPixelData(from: obstacleImage) else { return }
        
        checkCollision(keypoints: keypoints, pixelData: pixelData, imageWidth: obstacleImage.width, imageHeight: obstacleImage.height, tolerance: 10)
        
        if collisionPoints.count > 0 {
            print("Detected \(collisionPoints.count) collisions on obstacle \(imageName).")
        } else {
            print("No collisions detected on obstacle \(imageName)!")
        }
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            self.collisionPoints.removeAll()
        }
    }
    
    func getPixelData(from image: CGImage) -> [UInt8]? {
        let width = image.width
        let height = image.height
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let bitsPerComponent = 8
        
        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        )
        
        context?.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return pixelData
    }
    
    func checkCollision(keypoints: [KeyPoint], pixelData: [UInt8], imageWidth: Int, imageHeight: Int, tolerance: Int) {
        let bytesPerPixel = 4
        
        for point in keypoints {
            let x = Int(point.coordinate.x)
            let y = Int(point.coordinate.y)
            
            if x < 0 || y < 0 || x >= imageWidth || y >= imageHeight { continue }
            
            let index = (y * imageWidth + x) * bytesPerPixel
            let r = pixelData[index]
            let g = pixelData[index + 1]
            let b = pixelData[index + 2]
            let alpha = pixelData[index + 3]
            
            // Step 1: Check if the keypoint is inside a white pixel (white = near 255,255,255)
            let isWhite = r > 200 && g > 200 && b > 200 && alpha > 200
            if !isWhite { continue } // Skip if not white (no collision)
            
            // Step 2: Check surrounding pixels in the radius for transparency
            for dx in -tolerance...tolerance {
                for dy in -tolerance...tolerance {
                    if dx * dx + dy * dy > tolerance * tolerance { continue } // Keep it circular
                    
                    let checkX = x + dx
                    let checkY = y + dy
                    
                    if checkX < 0 || checkY < 0 || checkX >= imageWidth || checkY >= imageHeight { continue }
                    
                    let checkIndex = (checkY * imageWidth + checkX) * bytesPerPixel
                    let checkAlpha = pixelData[checkIndex + 3]
                    
                    if checkAlpha < 50 { // Transparent pixel found!
                        print("Keypoint at (\(x), \(y)) is near transparency, ignoring collision.")
                    }
                }
            }
            
            // If we get here, the keypoint is in white and has no transparent pixels nearby.
            print("Collision detected at (\(x), \(y))")
            collisionPoints.append(CGPoint(x: x, y: y))
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
            self.skeleton = nil
            defer { self.isRunning = false }

            // Run pose estimation
            do {
                let result = try estimator.estimateSinglePose(on: pixelBuffer)

                DispatchQueue.main.async {
                    let image = UIImage(ciImage: CIImage(cvPixelBuffer: pixelBuffer))

                    // If score is too low, clear result remaining in the overlayView.
                    if result.score < self.minimumScore {
                        self.overlayView.image = image
                        return
                    }

                    self.overlayView.draw(at: image, person: result, collisions: self.collisionPoints)
                    self.skeleton = result.keyPoints
                }
            } catch {
                print("Error running pose estimation.")
                return
            }
        }
    }
}
