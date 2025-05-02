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
    @Published var shouldCheckCollisions: Bool = false
    @Published var takeScreenshot: Bool = false
    @Published var scoredImages: [String] = []
    @Published var screenshots: [UIImage] = []
    
    func updateGameState(with collisionCount: Int) {
        DispatchQueue.main.async { [self] in
            print("collisions: \(collisionCount)")
            if collisionCount > 8 {
                health = max(health - 1, 0)
                healthLostInLevel += 1
            } else if collisionCount > 4 && collisionCount <= 8 {
                score += 50
                scoreGainedInLevel += 50
            } else if collisionCount > 0 && collisionCount <= 4{
                score += 75
                scoreGainedInLevel += 75
            } else {
                score += 100
                scoreGainedInLevel += 100
            }
            
            //  total collisions for level
            collisionsInLevel += collisionCount
            
            // end of level sheesh
            if endOfLevel {
                if collisionsInLevel == 0 {
                    score += 100
                    scoreGainedInLevel += 100
                    print("Bonus for no collisions")
                }
                print("End of level: c = \(collisionsInLevel), h- = \(healthLostInLevel), s+ = \(scoreGainedInLevel)")
                collisionsInLevel = 0
                healthLostInLevel = 0
                scoreGainedInLevel = 0
            }
        }
    }
    
    func addImage(_ image: String) {
        DispatchQueue.main.async { [self] in
            scoredImages.append(image)
        }
    }
    
    func resetLevel() {
        DispatchQueue.main.async { [self] in
            health += healthLostInLevel
            score -= scoreGainedInLevel
            healthLostInLevel = 0
            scoreGainedInLevel = 0
            scoredImages.removeAll{ $0.hasPrefix("level\(currentLevel)") }
            clearScreenshots()
        }
    }
    
    func addScreenshot(_ image: UIImage) {
        DispatchQueue.main.async {
            if self.screenshots.count >= 8 {
                self.screenshots.removeFirst()
            }
            self.screenshots.append(image)
        }
    }

    func clearScreenshots() {
        screenshots.removeAll()
    }
}
