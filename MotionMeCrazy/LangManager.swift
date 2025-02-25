//
//  LangManager.swift
//  MotionMeCrazy
//
//  Created by Tea Lazareto on 2/24/25.
//
import SwiftUI
import Combine

class LanguageManager: ObservableObject {
    static let shared = LanguageManager() // Singleton instance

    @Published var selectedLanguage: String {
        didSet {
            UserDefaults.standard.set([selectedLanguage], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
        }
    }

    private init() {
        self.selectedLanguage = UserDefaults.standard.stringArray(forKey: "AppleLanguages")?.first ?? "en"
    }
}
