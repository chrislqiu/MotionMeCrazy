//
//  Pose.swift
//  MotionMeCrazy
//
//  Created by Elasia Rodriguez on 2/25/25.
//

import CoreGraphics

struct Pose {
    struct Joint: Hashable {
        let name: String
        var position: CGPoint
        var confidence: CGFloat

        init(name: String, position: CGPoint = .zero, confidence: CGFloat = 0.0) {
            self.name = name
            self.position = position
            self.confidence = confidence
        }
    }

    struct Edge {
        let from: String
        let to: String

        init(from: String, to: String) {
            self.from = from
            self.to = to
        }
    }

    static let joints: [String: Joint] = [
        "nose": Joint(name: "nose"),
        "leftEye": Joint(name: "leftEye"),
        "rightEye": Joint(name: "rightEye"),
        "leftEar": Joint(name: "leftEar"),
        "rightEar": Joint(name: "rightEar"),
        "leftShoulder": Joint(name: "leftShoulder"),
        "rightShoulder": Joint(name: "rightShoulder"),
        "leftElbow": Joint(name: "leftElbow"),
        "rightElbow": Joint(name: "rightElbow"),
        "leftWrist": Joint(name: "leftWrist"),
        "rightWrist": Joint(name: "rightWrist"),
        "leftHip": Joint(name: "leftHip"),
        "rightHip": Joint(name: "rightHip"),
        "leftKnee": Joint(name: "leftKnee"),
        "rightKnee": Joint(name: "rightKnee"),
        "leftAnkle": Joint(name: "leftAnkle"),
        "rightAnkle": Joint(name: "rightAnkle")
    ]

    static let edges: [Edge] = [
        Edge(from: "leftShoulder", to: "leftElbow"),
        Edge(from: "leftElbow", to: "leftWrist"),
        Edge(from: "rightShoulder", to: "rightElbow"),
        Edge(from: "rightElbow", to: "rightWrist"),
        Edge(from: "leftHip", to: "leftKnee"),
        Edge(from: "leftKnee", to: "leftAnkle"),
        Edge(from: "rightHip", to: "rightKnee"),
        Edge(from: "rightKnee", to: "rightAnkle"),
        Edge(from: "leftShoulder", to: "rightShoulder"),
        Edge(from: "leftHip", to: "rightHip"),
        Edge(from: "leftShoulder", to: "leftHip"),
        Edge(from: "rightShoulder", to: "rightHip")
    ]

    init(jointPositions : [Float]) {
        var joints = [String: Joint]
        var edges = [Edge]
        for jointPosition in jointPositions {

        }
    }
}