//
//  AppState.swift
//  MotionMeCrazy
//
//  Created by Ethan Donahue on 3/5/25.
//

import Combine

class AppState: ObservableObject {
    @Published var offlineMode: Bool = false
    @Published var loading: Bool = true
    @Published var darkMode: Bool = false
}
