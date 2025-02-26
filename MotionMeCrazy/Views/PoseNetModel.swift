//
//  PoseNetModel.swift
//  MotionMeCrazy
//
//  Created by Elasia Rodriguez on 2/20/25.
//

import CoreVideo
import TensorFlowLite

class PoseNetModel {
    private var interpreter: Interpreter!
    private var inputTensor: Tensor
    private var heatsTensor: Tensor
    private var offsetsTensor: Tensor
    private let imageMean: Float = 127.5
    private let imageStd: Float = 127.5

    init?() {
        guard let modelPath = Bundle.main.path(forResource: "posenet_mobilenet_v1_100_257x257_multi_kpt_stripped", ofType: "tflite") else {
            print("Failed to find model file.")
            return nil
        }

        do {
            interpreter = try Interpreter(modelPath: modelPath)
            try interpreter.allocateTensors()
            inputTensor = try interpreter.input(at: 0)
            heatsTensor = try interpreter.output(at: 0)
            offsetsTensor = try interpreter.output(at: 1)
        } catch {
            print("Failed to create TensorFlow Lite interpreter: \(error)")
            return nil
        }
    }

    func estimatePose(from pixelBuffer: CVPixelBuffer, completion: @escaping ([Person]) -> Void) {
        guard let resizedBuffer = resizePixelBuffer(pixelBuffer, to: CGSize(width: 257, height: 257)) else {
            print("Failed to resize pixel buffer.")
            completion([])
            return
        }

        do {
            guard let inputData = preprocess(pixelBuffer) else {
                print("Failed to preprocess")
                completion([])
                return
            }
            try interpreter.copy(inputData, toInputAt: 0)

            // Run inference by invoking the `Interpreter`.
            try interpreter.invoke()

            // Get the output `Tensor` to process the inference results.
            heatsTensor = try interpreter.output(at: 0)
            offsetsTensor = try interpreter.output(at: 1)
            
        } catch {
            print("Failed to invoke interpreter: ")
            completion([])
            return
        }

        guard let result = parsePoseData(to: pixelBuffer.size) else {
            print("Post-processing failed")
            completion([])
            return
        }

        completion([result])
    }

    private func preprocess(_ pixelBuffer: CVPixelBuffer) -> Data? {
        let sourcePixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer)
        assert(sourcePixelFormat == kCVPixelFormatType_32BGRA
            || sourcePixelFormat == kCVPixelFormatType_32ARGB)

        // Resize `targetSquare` of input image to `modelSize`.
        let dimensions = inputTensor.shape.dimensions
        let inputWidth = dimensions[1]
        let inputHeight = dimensions[2]
        let modelSize = CGSize(width: inputWidth, height: inputHeight)
        guard let thumbnail = pixelBuffer.resized(to: modelSize) else {
          return nil
        }
        // Remove the alpha component from the image buffer to get the initialized `Data`.
        return thumbnail.rgbData(isModelQuantized: false, imageMean: imageMean, imageStd: imageStd)
      }

    /// Parses PoseNet model output to extract keypoints.
    private func parsePoseData(to viewSize: CGSize) -> Person? {
        let heats = FlatArray<Float32>(tensor: heatsTensor)
        let offsets = FlatArray<Float32>(tensor: offsetsTensor)
        let outputHeight = heats.dimensions[1]
        let outputWidth = heats.dimensions[2]
        let keyPointSize = heats.dimensions[3]
        // MARK: Find position of each key point
        // Finds the (row, col) locations of where the keypoints are most likely to be. The highest
        // `heats[0, row, col, keypoint]` value, the more likely `keypoint` being located in (`row`,
        // `col`).
        let keypointPositions = (0..<keyPointSize).map { keypoint -> (Int, Int) in
            var maxValue = heats[0, 0, 0, keypoint]
            var maxRow = 0
            var maxCol = 0
            for row in 0..<outputHeight {
                for col in 0..<outputWidth {
                    if heats[0, row, col, keypoint] > maxValue {
                        maxValue = heats[0, row, col, keypoint]
                        maxRow = row
                        maxCol = col
                    }
                }
            }
            return (maxRow, maxCol)
        }

        // MARK: Calculates total confidence score
        // Calculates total confidence score of each key position.
        let totalScoreSum = keypointPositions.enumerated().reduce(0.0) { accumulator, elem -> Float32 in
            accumulator + sigmoid(heats[0, elem.element.0, elem.element.1, elem.offset])
        }
        let totalScore = totalScoreSum / Float32(keyPointSize)

        // MARK: Calculate key point position on model input
        // Calculates `KeyPoint` coordination model input image with `offsets` adjustment.
        let dimensions = inputTensor.shape.dimensions
        let inputHeight = dimensions[1]
        let inputWidth = dimensions[2]
        let coords = keypointPositions.enumerated().map { index, elem -> (y: Float32, x: Float32) in
            let (y, x) = elem
            let yCoord =
                Float32(y) / Float32(outputHeight - 1) * Float32(inputHeight)
                + offsets[0, y, x, index]
            let xCoord =
                Float32(x) / Float32(outputWidth - 1) * Float32(inputWidth)
                + offsets[0, y, x, index + keyPointSize]
            return (y: yCoord, x: xCoord)
        }

        // MARK: Transform key point position and make lines
        // Make `Result` from `keypointPosition'. Each point is adjusted to `ViewSize` to be drawn.
        var result = Person(keyPoints: [], score: totalScore)

        for (index, part) in BodyPart.allCases.enumerated() {
            let x = CGFloat(coords[index].x) * viewSize.width / CGFloat(inputWidth)
            let y = CGFloat(coords[index].y) * viewSize.height / CGFloat(inputHeight)
            let keyPoint = KeyPoint(bodyPart: part, coordinate: CGPoint(x: x, y: y))
            result.keyPoints.append(keyPoint)
        }

        return result
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

    private func sigmoid(_ x: Float32) -> Float32 {
        return (1.0 / (1.0 + exp(-x)))
    }
}

fileprivate struct FlatArray<Element: AdditiveArithmetic> {
    private var array: [Element]
    var dimensions: [Int]

    init(tensor: Tensor) {
        dimensions = tensor.shape.dimensions
        array = tensor.data.toArray(type: Element.self)
    }

    private func flatIndex(_ indices: [Int]) -> Int {
        guard indices.count == dimensions.count else {
        fatalError("Invalid index: got \(indices.count) index(es) for \(dimensions.count) index(es).")
        }

        var result = 0
        for (dimension, index) in zip(dimensions, indices) {
        guard dimension > index else {
            fatalError("Invalid index: \(index) is bigger than \(dimension)")
        }
        result = dimension * result + index
        }
        return result
    }

    subscript(_ index: Int...) -> Element {
        get {
            return array[flatIndex(index)]
        }
        set(newValue) {
            array[flatIndex(index)] = newValue
        }
    }
}

enum BodyPart: String, CaseIterable {
    case nose = "nose"
    case leftEye = "left eye"
    case rightEye = "right eye"
    case leftEar = "left ear"
    case rightEar = "right ear"
    case leftShoulder = "left shoulder"
    case rightShoulder = "right shoulder"
    case leftElbow = "left elbow"
    case rightElbow = "right elbow"
    case leftWrist = "left wrist"
    case rightWrist = "right wrist"
    case leftHip = "left hip"
    case rightHip = "right hip"
    case leftKnee = "left knee"
    case rightKnee = "right knee"
    case leftAnkle = "left ankle"
    case rightAnkle = "right ankle"

    /// Get the index of the body part in the array returned by pose estimation models.
    var position: Int {
        return BodyPart.allCases.firstIndex(of: self) ?? 0
    }
}

/// A body keypoint (e.g. nose) 's detection result.
struct KeyPoint {
    var bodyPart: BodyPart = .nose
    var coordinate: CGPoint = .zero
    var score: Float32 = 0.0
}

/// A person detected by a pose estimation model.
struct Person {
    var keyPoints: [KeyPoint]
    var score: Float32
}
