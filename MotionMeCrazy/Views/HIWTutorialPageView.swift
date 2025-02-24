import SwiftUI

//
//  HIWTutorialPageView.swift
//  MotionMeCrazy
//
//  Created by Jillian Urgello on 2/23/25.
//

struct HIWTutorialPageView: View {
    @State private var isPlaying = false // will not be true until tutorial is completed
    @State private var tutorialStep = 0  // track tutorial step
    @State private var showTutorial = true  // toggle tutorial visibility
    
    var body: some View {
        ZStack{
            
            // main HIW game play
            HIWGamePageView()
            
            
            
            if showTutorial {
                Color.black.opacity(0.2)  // dim background
                    .edgesIgnoringSafeArea(.all)
                
                highlightSection()
                
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
                HIWGamePageView()
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
    
    // adds a highlight effect for each tutorial step
    @ViewBuilder
    func highlightSection() -> some View {
        GeometryReader { geometry in
            let highlightRect = highlightFrame(for: tutorialStep, in: geometry)

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

    // determines highlight position and size based on tutorial step
    func highlightFrame(for step: Int, in geometry: GeometryProxy) -> CGRect {
        switch step {
        case 0: // score section
            return CGRect(x: 20, y: 185, width: 375, height: 40)
        case 1: // health section
            return CGRect(x: 20, y: 220, width: 375, height: 40)
        case 2: // progress section
            return CGRect(x: 20, y: 255, width: 375, height: 40)
        case 3: // pause button (top-right)
            return CGRect(x: geometry.size.width - 60, y: 108, width: 50, height: 50)
        default:
            return CGRect.zero
        }
    }

}

#Preview {
    HIWTutorialPageView()
}
