import SwiftUI
//
//  HIWGamePageView.swift
//  MotionMeCrazy
//
//  Created by Jillian Urgello on 2/23/25.
//

struct HIWGamePageView:View {
    // game buttons
    @Environment(\.presentationMode) var presentationMode
    @State private var showSettings = false  // shows settings pop up
    @State private var showPauseMenu = false  // shows pause menu pop up
    @State private var showQuitConfirmation = false // shows quit
    @State private var isPlaying = true  // checks if game is active
    
    // game stats
    @State private var score: Int = 1000
    @State private var health: Double = 30  // Adjust based on game logic
    @State private var maxHealth: Double = 100
    @State private var progress: String = "Level 1/10"
    
    var body: some View {
        ZStack{
            Image("background")
                .resizable()
                .ignoresSafeArea()
            
            
            
            VStack(alignment: .leading, spacing: 10) {
                VStack() {
                    HStack() {
                        Spacer()
                        
                        // pause button during gameplay
                        Button(action: {
                            showPauseMenu = true
                        }) {
                            Image(systemName: "pause.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40, alignment: .topLeading)
                                .foregroundColor(.darkBlue)
                                .padding()
                        }
                        .accessibilityIdentifier("pauseButton")
                    }
                    
                    
                }
                VStack() {
                    
                    // Score Section
                    HStack {
                        CustomText(config: CustomTextConfig(text: "Score", titleColor: .darkBlue, fontSize: 20))
                            .font(.headline)
                            .bold()
                        Spacer()
                        CustomText(config: CustomTextConfig(text:"\(score)", titleColor: .darkBlue, fontSize: 18))
                            .font(.body)
                        
                    }
                    
                    // Health Section
                    HStack {
                        CustomText(config: CustomTextConfig(text: "Health", titleColor: .darkBlue, fontSize: 20))
                            .font(.headline)
                            .bold()
                        Spacer()
                        CustomText(config: CustomTextConfig(text:"0", titleColor: .darkBlue, fontSize: 18))
                            .font(.body)
                        ProgressView(value: health, total: maxHealth)
                            .progressViewStyle(LinearProgressViewStyle())
                            .frame(width: 50)  // Adjust width as needed
                            .tint(.darkBlue)
                        CustomText(config: CustomTextConfig(text:"100", titleColor: .darkBlue, fontSize: 18))
                            .font(.body)
                    }
                    
                    // Progress Section
                    HStack {
                        CustomText(config: CustomTextConfig(text: "Progress", titleColor: .darkBlue, fontSize: 20))
                            .font(.headline)
                            .bold()
                        Spacer()
                        CustomText(config: CustomTextConfig(text:"\(progress)", titleColor: .darkBlue, fontSize: 18))
                            .font(.body)
                    }
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)  
                .padding(.horizontal)
                Spacer()
                
            }
            
            // pause menu for game
            if showPauseMenu {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showPauseMenu = false
                    }

                PauseMenuView(
                    isPlaying: $isPlaying, showPauseMenu: $showPauseMenu,
                    showSettings: $showSettings, showQuitConfirmation: $showQuitConfirmation
                )
                .frame(width: 300, height: 300)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 20)
                .accessibilityIdentifier("pauseMenuView")
            }
            
        }
        
    }
    
}


#Preview {
    HIWGamePageView()
}
