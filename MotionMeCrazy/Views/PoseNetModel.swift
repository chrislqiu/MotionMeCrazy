//
//  PoseNetModel.swift
//  MotionMeCrazy
//
//  Created by Elasia Rodriguez on 2/2/25.
//

import CoreVideo
import TensorFlowLite

class PoseNetModel {
    private var interpreter: Interpreter!

    init?() {
        guard let modelPath = Bundle.main.path(forResource: "posenet_mobilenet_v1_100_257x257_multi_kpt_stripped", ofType: "tflite") else {
            print("Failed to find model file.")
            return nil
        }

        do {
            interpreter = try Interpreter(modelPath: modelPath)
            try interpreter.allocateTensors()
        } catch {
            print("Failed to create TensorFlow Lite interpreter: \(error)")
            return nil
        }
    }

    func estimatePoses(from pixelBuffer: CVPixelBuffer, completion: @escaping ([Pose]) -> Void) {
        guard let resizedBuffer = resizePixelBuffer(pixelBuffer, to: CGSize(width: 257, height: 257)) else {
            print("Failed to resize pixel buffer.")
            completion([])
            return
        }

        do {
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

    /// Converts a CVPixelBuffer to TensorFlow-compatible Data
    private func convertToTensorData(pixelBuffer: CVPixelBuffer, tensor: Tensor) -> Data {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            print("Failed to get pixel buffer base address.")
            return Data()
        }

        let byteCount = CVPixelBufferGetDataSize(pixelBuffer)
        return Data(bytes: baseAddress, count: byteCount)
    }

    /// Parses PoseNet model output to extract keypoints.
    private func parsePoseData(_ outputData: [Float]) -> [Pose] {
        var pose: Pose = Pose()
        for index in outputData {
            // TODO
        }
        var poses: [Pose] = []
        // Process outputData and populate poses
        return poses
    }

    /// Resizes a pixel buffer to the target size.
    private func resizePixelBuffer(_ pixelBuffer: CVPixelBuffer, to size: CGSize) -> CVPixelBuffer? {
        var resizedPixelBuffer: CVPixelBuffer?
        let attributes: [CFString: Any] = [
            kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey: Int(size.width),
            kCVPixelBufferHeightKey: Int(size.height),
            kCVPixelBufferIOSurfacePropertiesKey: [:]
        ]

        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height),
                                         kCVPixelFormatType_32BGRA, attributes as CFDictionary, &resizedPixelBuffer)

        guard status == kCVReturnSuccess, let buffer = resizedPixelBuffer else {
            print("Failed to create resized pixel buffer.")
            return nil
        }

        return buffer
    }
}
