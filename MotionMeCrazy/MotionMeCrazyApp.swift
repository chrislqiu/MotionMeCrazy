//
//  MotionMeCrazyApp.swift
//  MotionMeCrazy
//
//  Created by Chris Qiu on 2/6/25.
//

import SwiftUI
import UserNotifications

@main
struct MotionMeCrazyApp: App {
    @StateObject private var appState = AppState()
    @StateObject var webSocketManager = WebSocketManager()
    
    init() {
        requestNotificationPermission()
        scheduleDailyReminderNotification(hour: 17, minute: 00, message: "Don't forget to check in today!")
    }
    
    var body: some Scene {
        WindowGroup {
            LandingPageView()
                .environmentObject(appState)
                .environmentObject(webSocketManager)
                .onAppear {
                    checkServerStatus()
                }
        }
    }
    
    private func checkServerStatus() {
        guard let url = URL(string: APIHelper.getBaseURL() + "/status") else { return }
        
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

func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if let error = error {
            print("Notification permission error: \(error.localizedDescription)")
        } else {
            print("Notification permission granted: \(granted)")
        }
    }
}

func scheduleDailyReminderNotification(hour: Int, minute: Int, message: String) {
    let content = UNMutableNotificationContent()
    content.title = "Daily Reminder"
    content.body = message
    content.sound = .default

    // Create a calendar date trigger
    var dateComponents = DateComponents()
    dateComponents.hour = hour
    dateComponents.minute = minute

    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

    let request = UNNotificationRequest(identifier: "daily_reminder", content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error scheduling daily reminder: \(error.localizedDescription)")
        } else {
            print("Daily reminder scheduled at \(hour):\(String(format: "%02d", minute))")
        }
    }
}
