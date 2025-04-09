//
//  CountdownView.swift
//  MotionMeCrazy
//
//  Created by Chris Qiu on 4/8/25.
//

import SwiftUI

struct CountdownView: View {
    let value: Int

    var body: some View {
        Image("countdown\(value)")
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 200)
            .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
            .allowsHitTesting(false)
    }
}

/// A manager for handling countdown functionality
class CountdownManager: ObservableObject {
    @Published var isActive = false
    @Published var value = 3
    
    private var timer: Timer?
    private var completion: (() -> Void)?
    
    /// Starts a countdown from the specified value
    /// - Parameters:
    ///   - from: The starting value (default is 3)
    func start(from: Int = 3, onComplete: @escaping () -> Void) {
        // Reset state
        stop()
        value = from
        isActive = true
        completion = onComplete
        
        // Start timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.value > 1 {
                self.value -= 1
            } else {
                self.stop()
                self.completion?()
            }
        }
    }
    
    /// Stops the current countdown
    func stop() {
        timer?.invalidate()
        timer = nil
        isActive = false
    }
    
    deinit {
        stop()
    }
}

#Preview {
    CountdownView(value: 3)
}
