import SwiftUI

//
//  HIWTutorialPageView.swift
//  MotionMeCrazy
//
//  Created by Jillian Urgello on 2/23/25.
//

struct HIWTutorialPageView: View {
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
                CustomHeader(config: CustomHeaderConfig(title: "Hole in the Wall Tutorial"))

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
            .background(Color(UIColor.systemGray6))  // Light background
            .cornerRadius(10)  // Optional for styling
            .padding(.horizontal)
        }
    }
    
}

#Preview {
    HIWTutorialPageView()
}
