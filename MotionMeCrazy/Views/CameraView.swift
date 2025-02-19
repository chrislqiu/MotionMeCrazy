//
//  MainPageView.swift
//  MotionMeCrazy
//
//  Created by Tea Lazareto on 2/18/25.
//

import SwiftUI
import AVFoundation

//to show camera view *** TEMPORARY FOR NOW UNTIL WE FIGURE OUT TENSOR FLOW
struct CameraView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) { }
}

class CameraViewController: UIViewController {
    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        NotificationCenter.default.addObserver(self, selector: #selector(handleRotation), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    private func setupCamera() {
        captureSession.sessionPreset = .high

        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: frontCamera) else { return }

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.bounds
        view.layer.addSublayer(previewLayer!)

        captureSession.startRunning()
    }

    @objc private func handleRotation() {
        guard let previewLayer = previewLayer else { return }
        previewLayer.frame = view.bounds

        if let connection = previewLayer.connection, connection.isVideoOrientationSupported {
            switch UIDevice.current.orientation {
            case .portrait:
                connection.videoOrientation = .portrait
            case .portraitUpsideDown:
                connection.videoOrientation = .portraitUpsideDown
            case .landscapeLeft:
                connection.videoOrientation = .landscapeRight
            case .landscapeRight:
                connection.videoOrientation = .landscapeLeft
            default:
                break
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

