//
//  CustomButton.swift
//  MotionMeCrazy
//
//  Created by Rachel La on 2/6/25.
//

import SwiftUI

struct CustomButtonConfig {
    let title: String
    let action: () -> Void
    var titleColor: Color = .white
    var fontSize: CGFloat = 20
}

struct CustomButton: View {
    let config: CustomButtonConfig
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(height: 57)
                .background {
                    Color(.darkBlue)
                }
                .cornerRadius(15)
            Text(config.title)
                .foregroundColor(config.titleColor)
                .font(.system(size: config.fontSize, weight: .bold))
        }
        .onTapGesture {
            config.action()
        }
    }
}

#Preview {
    CustomButton(config: .init(title: "Test",
                 action: {
        
    }))
}
