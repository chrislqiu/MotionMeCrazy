//
//  CustomButton.swift
//  MotionMeCrazy
//
//  Created by Rachel La on 2/6/25.
//

import SwiftUI

struct CustomButtonConfig {
    let title: String
    let width: CGFloat
    let buttonColor: Color
    var action: (() -> Void)? // optional
    var titleColor: Color = .white
    var fontSize: CGFloat = 20
    var destination: AnyView? = nil // optional
}

struct CustomButton: View {
    let config: CustomButtonConfig
    
    var body: some View {
        if let destination = config.destination {
            NavigationLink(destination: destination) {
                buttonView
            }
        } else {
            Button(action: { config.action?() }) {
                buttonView
            }
        }
    }
    
    private var buttonView: some View {
        Text(config.title)
            .foregroundColor(config.titleColor)
            .font(.system(size: config.fontSize, weight: .bold))
            .frame(width: config.width, height: 50)
            .background(config.buttonColor)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(config.titleColor, lineWidth: 5)
            )
            .cornerRadius(15)
    }
}


#Preview {
    CustomButton(config: .init(title: "Test", width: 100, buttonColor: .darkBlue,
                 action: {
        
    }))
}
