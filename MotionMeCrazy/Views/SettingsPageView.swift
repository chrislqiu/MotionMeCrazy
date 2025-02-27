//
//  SettingsPageView.swift
//  MotionMeCrazy
//  Tea Lazareto 2/12/2025
//
import SwiftUI

struct SettingsPageView: View {
    @State private var audioLevel: Double = 0.5
    @State private var showThemePopup: Bool = false
    @State private var showLanguagePopup: Bool = false
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                settingsContent
            }
            .padding()
            
            if showThemePopup {
                ThemeSelectionPopup(showThemeOpt: $showThemePopup)
                    .transition(.scale)
            }
            if showLanguagePopup {
                LanguageSelectionPopup(showLangOpt: $showLanguagePopup)
                    .transition(.scale)
            }
        }
        .animation(.easeInOut, value: showThemePopup) //transition for opening
        .animation(.easeInOut, value: showLanguagePopup) //transition for opening
    }
    
    //all the content presented on settings (MAIN) view
    var settingsContent: some View {
        VStack(spacing: 20) {
            CustomHeader(config: .init(title: "Settings"))
            
            VStack(alignment: .leading) {
                CustomText(config: .init(text: "Audio Level"))
                Slider(value: $audioLevel, in: 0...1)
                    .accentColor(.darkBlue)
            }
            .padding()
            
            CustomButton(config: .init(title: "Change Theme", width: 200, buttonColor: .darkBlue) {
                showThemePopup = true
            })
            
            CustomButton(config: .init(title: "Change Language", width: 200, buttonColor: .darkBlue) {
                showLanguagePopup = true
            })
        }
    }
}

// pop up for theme selection (may just remove this completely later idk)
struct ThemeSelectionPopup: View {
    @Binding var showThemeOpt: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                //exit
                Button(action: { showThemeOpt = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title)
                }
            }
            
            CustomText(config: .init(text: "Theme Options:"))
            
            VStack(spacing: 5) {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
                    .background(
                        Image("background")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 50)
                            .clipped()
                    )
                    .frame(width: 120, height: 50)
                    .cornerRadius(10)
                
                CustomButton(config: .init(title: "Default", width: 150, buttonColor: .darkBlue) {})
            }
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(10)
            .shadow(radius: 5)
        }
        .padding()
        .frame(width: 250)
        .background(Color.white.opacity(0.95))
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}

//popup for language selection (also might remove this later, we will see)
struct LanguageSelectionPopup: View {
    @Binding var showLangOpt: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                //exit
                Button(action: { showLangOpt = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title)
                }
            }
            
            CustomText(config: .init(text: "Language Options:"))
            
            CustomButton(config: .init(title: "English", width: 100, buttonColor: .darkBlue) {})
        }
        .padding()
        .frame(width: 250)
        .background(Color.white.opacity(0.95))
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}

#Preview {
    SettingsPageView()
}
