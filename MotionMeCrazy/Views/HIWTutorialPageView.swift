import SwiftUI

//
//  HIWTutorialPageView.swift
//  MotionMeCrazy
//
//  Created by Jillian Urgello on 2/23/25.
//

struct HIWTutorialPageView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isPlaying = false // will not be true until tutorial is completed
    @State private var tutorialStep = 0  // track tutorial step
    @State private var showTutorial = true  // toggle tutorial visibility
    @State private var sectionFrames: [Int: CGRect] = [:]

    
    
    var body: some View {
        ZStack{
            
            // main HIW game play
            HIWGamePageView(sectionFrames: Binding($sectionFrames))
            
            if showTutorial {
                Color.black.opacity(0.5)  // dim background
                    .edgesIgnoringSafeArea(.all)
                
                
                // highlight game sections
                if let highlightRect = sectionFrames[tutorialStep] {
                    highlightSection(rect: highlightRect)
                }
                
                // highlight pause button
                if tutorialStep == 3 {
                    highlightPauseButton()
                    
                }
                
                VStack {
                    Spacer()

                    // tutorial textbox
                    CustomText(config: CustomTextConfig(text: tutorialText(for: tutorialStep), titleColor: .darkBlue, fontSize: 18))
                        .frame(width: 350, height: 60)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding()

                    HStack {
                        // skip tutorial Button
                        CustomButton(config: CustomButtonConfig(title: "Skip", width: 70, buttonColor: .darkBlue, action: {
                                showTutorial = false
                        }))

                        Spacer()
                        
                        // back tutorial button
                        CustomButton(config: CustomButtonConfig(title: "Back", width: 70, buttonColor: .darkBlue, action: {
                                if tutorialStep > 0 {
                                    tutorialStep -= 1
                                }
                        }))
                        
                        Spacer()
                        
                        // next tutorial button
                        CustomButton(config: CustomButtonConfig(title: "Next", width: 70, buttonColor: .darkBlue, action: {
                                if tutorialStep < 4 {
                                    tutorialStep += 1
                                } else {
                                    showTutorial = false  // end tutorial
                                }
                        }))
                    }
                    .frame(width: 300)
                }
                .padding()
                .transition(.opacity)
            } else {
                
                Button(action: {
                    isPlaying = true
                    //HIWGameLobbyView()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.darkBlue)
                }
                .accessibilityIdentifier("playButton")
                                
            }
            
            if isPlaying {
                // when we update the HIW game with the stats, use this page
                //HIWGamePageView()
            }
        }
    }
    
    func tutorialText(for step: Int) -> String {
            switch step {
            case 0: return "This is your score. It increases as you progress in the game!"
            case 1: return "This is your health. If it reaches zero, you lose!"
            case 2: return "This is your progress. It shows what level you’re on."
            case 3: return "Tap the pause button to pause the game."
            case 4: return "That's the tutorial! Press play to start the game!"
            default: return "Welcome to the game!"
            }
    }
    
    @ViewBuilder
        func highlightSection(rect: CGRect) -> some View {
            GeometryReader { _ in
                Color.black.opacity(0.7)
                    .mask(
                        Rectangle()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: rect.width + 18, height: rect.height + 10)
                                    .position(x: rect.midX + 10, y: rect.midY - 70)
                                    .blendMode(.destinationOut)
                            )
                    )
                    .edgesIgnoringSafeArea(.all)
            }
        }
    
    // adds a highlight effect for pause step
    @ViewBuilder
    func highlightPauseButton() -> some View {
        GeometryReader { geometry in
            let highlightRect = CGRect(x: geometry.size.width - 60, y: 108, width: 50, height: 50)

            // overlay with cut-out effect
            Color.black.opacity(0.6)
                .mask(
                    Rectangle()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: highlightRect.width, height: highlightRect.height)
                                .position(x: highlightRect.midX, y: highlightRect.midY)
                                .blendMode(.destinationOut)
                        )
                )
                .edgesIgnoringSafeArea(.all)
        }
    }
}

#Preview {
    HIWTutorialPageView()
}
