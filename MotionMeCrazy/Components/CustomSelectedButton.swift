//
//  CustomSelectedButton.swift
//  MotionMeCrazy
//
//  Created by Rachel La on 2/11/25.
//

import SwiftUI

struct CustomSelectedButtonConfig {
    let title: String
    let width: CGFloat
    let action: () -> Void
    var titleColor: Color = .darkBlue
    var fontSize: CGFloat = 20
}

struct CustomSelectedButton: View {
    @EnvironmentObject var appState: AppState
    let config: CustomSelectedButtonConfig
    var body: some View {
        ZStack {
            Button(action: {config.action()}) {
                Text(config.title)
                    .foregroundColor(config.titleColor)
                    .font(.system(size: config.fontSize, weight: .bold))
                    .padding(10)
            }
            .foregroundColor(.clear)
            .frame(width: config.width, height: 50)
            .background {
                Color.white.opacity(0.75)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(config.titleColor, lineWidth: 5)
            )
            .cornerRadius(15)
            .disabled(true)

        }
    }
}

#Preview {
    CustomSelectedButton(config: .init(title: "Test", width: 100,
                 action: {
        
    }))
}
