import SwiftUI
import AVFoundation
//
//  FailedLevelScreenView.swift
//  MotionMeCrazy
//
//  Created by Jillian Urgello on 3/7/25.
//

struct FailedLevelScreenView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState

    @State private var showQuitConfirmation = false // shows quit
    var levelNumber: Int
    var totalLevels: Int
    var score: Int
    var health: Double
    var onRetryLevel: () -> Void
    var onQuitGame: () -> Void
    
    @Binding var isMuted: Bool
    @Binding var audioPlayer: AVAudioPlayer?
        
        var body: some View {
            ZStack {
                // darkened background overlay
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        // prevent accidental dismiss
                    }

                VStack(spacing: 20) {
                    CustomHeader(config: .init(title: String(format: appState.localized("Level %d/%d Failed!"), levelNumber, totalLevels), fontSize: 26))
                    
                    VStack(spacing: 10) {
                        CustomText(config: CustomTextConfig(text: String(format: appState.localized("Score: %d"),score), fontSize:20))
                        CustomText(config: CustomTextConfig(text: String(format: appState.localized("Remaining Health: %d"),Int(health)), fontSize:20))
                    }

                    HStack(spacing: 30) {
                        // retry level button
                        CustomButton(config: CustomButtonConfig(title: appState.localized("Retry Level"), width: 140, buttonColor: .darkBlue, action: {
                            onRetryLevel() // TODO: add logic for retrying  current level
                            }
                       ))
                        
                        // quit game button
                        CustomButton(config: CustomButtonConfig(title: appState.localized("Quit Game"), width: 140, buttonColor: .darkBlue, action: {
                                //TODO: add logic for going back to home screen
                                //onQuitGame()
                                showQuitConfirmation = true
                            }
                       ))
                        .accessibilityIdentifier("quitGameButton")
                        .alert(appState.localized("Are you sure you want to quit?"), isPresented: $showQuitConfirmation) {
                            Button(appState.localized("No"), role: .cancel) { }
                            Button(appState.localized("Yes"), role: .destructive) {
                                        isMuted = true
                                        audioPlayer?.stop()
                                        presentationMode.wrappedValue.dismiss()
                                        
                                    }
                                }
                    }
                    .padding(.top, 10)
                }
                .padding()
                .background(appState.darkMode ? .darkBlue.opacity(0.9) : Color.white.opacity(0.9))
                .cornerRadius(20)
                .shadow(radius: 10)
            }
        }
    
}

//#Preview {
//    FailedLevelScreenView(levelNumber:1, totalLevels: 4, score:1, health:1, onRetryLevel: {
//    },
//    onQuitGame: {
//    })
//}



