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
