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
    @EnvironmentObject var appState: AppState

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
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(config.buttonColor)
                .frame(width: config.width, height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(config.titleColor, lineWidth: 3)
                )
                .shadow(color: .black.opacity(0.5), radius: 1, x: 1, y: 1)


            Text(config.title)
                .foregroundColor(config.titleColor)
                .font(.system(size: config.fontSize, weight: .bold))
                .shadow(color: .black.opacity(0.5), radius: 1, x: 1, y: 1)
        }
    }
}


#Preview {
    CustomButton(config: .init(title: "Test", width: 100, buttonColor: .darkBlue,
                 action: {
        
    }))
}
