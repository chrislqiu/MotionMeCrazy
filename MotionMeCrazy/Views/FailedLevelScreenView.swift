import SwiftUI
//
//  FailedLevelScreenView.swift
//  MotionMeCrazy
//
//  Created by Jillian Urgello on 3/7/25.
//

struct FailedLevelScreenView: View {
    @Environment(\.presentationMode) var presentationMode
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
                    CustomText(config: CustomTextConfig(text: "Level \(levelNumber)/\(totalLevels) Failed!", titleColor: .darkBlue, fontSize: 30))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 10) {
                        CustomText(config: CustomTextConfig(text: "Score: \(score)", titleColor: .white, fontSize:20))
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        CustomText(config: CustomTextConfig(text: "Remaining Health: \(Int(health))", titleColor: .white, fontSize:20))
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.darkBlue.opacity(0.8))
                    .cornerRadius(15)

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
                .background(Color.white.opacity(0.9))
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



