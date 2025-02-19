//
//  SettingsPageView.swift
//  MotionMeCrazy
// Tea Lazareto 2/12/2025
//

import SwiftUI

struct SettingsPageView: View {
    @State private var audioLevel: Double = 0.5
    @State private var selectedTab: Int = 0
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    TabButton(title: "Settings", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }.accessibilityIdentifier("settingsButton")
                    TabButton(title: "Game Settings", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }.accessibilityIdentifier("gameSettingsButton")
                }
                .padding()
                
                // Show settings content when "Settings" tab is selected
                if selectedTab == 0 {
                    settingsContent
                } else {
                    gameSettingsContent
                }
            }
            .padding()
        }
    }
    
    var settingsContent: some View {
        VStack(spacing: 20) {
            CustomHeader(config: .init(title: "Settings"))
            
            // audio
            VStack(alignment: .leading) {
                CustomText(config: .init(text: "Audio Level"))
                Slider(value: $audioLevel, in: 0...1)
                    .accentColor(.darkBlue)
                 
                    
            }
            .padding()
            
            CustomButton(config: .init(title: "Change Theme", width: 200, buttonColor: .darkBlue) {}).accessibilityIdentifier("themeButton")
            
            CustomButton(config: .init(title: "Change Language", width: 200,buttonColor: .darkBlue) {}).accessibilityIdentifier("languageButton")
        }
    }
    
    // idk if necessary
    var gameSettingsContent: some View {
        VStack(spacing: 20) {
            CustomHeader(config: .init(title: "Game Settings"))               .accessibilityIdentifier("gameSettingsScreen")

            
            // Placeholder
            CustomText(config: .init(text: "Game Settings"))
        }
        .padding()
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .padding()
                .background(isSelected ? Color(.darkBlue) : Color.clear) // Use darkBlue for selected background
                .foregroundColor(isSelected ? .white : Color(.darkBlue)) // White text for selected, darkBlue for unselected
                .border(isSelected ? Color.clear : Color(.darkBlue), width: 2) // darkBlue border for unselected
                .cornerRadius(10)
        }
    }
}

#Preview {
    SettingsPageView()
}
