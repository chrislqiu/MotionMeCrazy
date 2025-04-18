import SwiftUI
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
        
        var body: some View {
            ZStack {
                // darkened background overlay
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        // prevent accidental dismiss
                    }

                VStack(spacing: 20) {
                    CustomHeader(config: .init(title: "Level \(levelNumber)/\(totalLevels) Failed!", fontSize: 26))
                    
                    VStack(spacing: 10) {
                        CustomText(config: CustomTextConfig(text: "Score: \(score)", fontSize:20))
                        CustomText(config: CustomTextConfig(text: "Remaining Health: \(Int(health))", fontSize:20))
                    }

                    HStack(spacing: 30) {
                        // retry level button
                        CustomButton(config: CustomButtonConfig(title: "Retry Level", width: 140, buttonColor: .darkBlue, action: {
                            onRetryLevel() // TODO: add logic for retrying  current level
                            }
                       ))
                        
                        // quit game button
                        CustomButton(config: CustomButtonConfig(title: "Quit Game", width: 140, buttonColor: .darkBlue, action: {
                                //TODO: add logic for going back to home screen
                                //onQuitGame()
                                showQuitConfirmation = true
                            }
                       ))
                        .accessibilityIdentifier("quitGameButton")
                        .alert("Are you sure you want to quit?", isPresented: $showQuitConfirmation) {
                                    Button("No", role: .cancel) { }
                                    Button("Yes", role: .destructive) {
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

#Preview {
    FailedLevelScreenView(levelNumber:1, totalLevels: 4, score:1, health:1, onRetryLevel: {
    },
    onQuitGame: {
    })
}



