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
    let action: () -> Void
    var titleColor: Color = .white
    var fontSize: CGFloat = 20
}

struct CustomButton: View {
    let config: CustomButtonConfig
    var body: some View {
        ZStack {
            Button(action: {config.action()}) {
                Text(config.title)
                    .foregroundColor(config.titleColor)
                    .font(.system(size: config.fontSize, weight: .bold))
            }
            .foregroundColor(.clear)
            .frame(width: config.width, height: 50)
            .background {
                Color(.darkBlue)
            }
            .cornerRadius(15)
        }
    }
}

#Preview {
    CustomButton(config: .init(title: "Test", width: 100,
                 action: {
        
    }))
}
