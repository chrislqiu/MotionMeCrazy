//
//  GameState.swift
//  MotionMeCrazy
//
//  Created by Tea Lazareto on 4/29/25.
//

import SwiftUI

//shared game data for the view controller and hole in the wall
class GameState: ObservableObject {
    @Published var score: Int = 0
    @Published var health: Double = 5
    @Published var maxHealth: Double = 5
    @Published var currentLevel: Int = 1
    @Published var collisionsInLevel: Int = 0
    @Published var healthLostInLevel: Double = 0
    @Published var scoreGainedInLevel: Int = 0
    @Published var endOfLevel: Bool = false
}
