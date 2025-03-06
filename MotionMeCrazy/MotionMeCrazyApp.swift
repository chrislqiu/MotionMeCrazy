//
//  MotionMeCrazyApp.swift
//  MotionMeCrazy
//
//  Created by Chris Qiu on 2/6/25.
//

import SwiftUI

@main
struct MotionMeCrazyApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            LandingPageView()
                .environmentObject(appState)
                .onAppear {
                    checkServerStatus()
                }
        }
    }
    
    private func checkServerStatus() {
        guard let url = URL(string: "http://localhost:3000/status") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    appState.offlineMode = false
                } else {
                    appState.offlineMode = true
                }
                appState.loading = false
            }
        }.resume()
    }
}
