//
//  CustomText.swift
//  MotionMeCrazy
//
//  Created by Rachel La on 2/6/25.
//

import SwiftUI

struct CustomTextConfig {
    let text: String
    var titleColor: Color = .darkBlue
    var fontSize: CGFloat = 20
}

struct CustomText: View {
    @EnvironmentObject var appState: AppState
    let config: CustomTextConfig
    var body: some View {
        Text(config.text)
            .foregroundColor( appState.darkMode ? .white : .darkBlue)
            .font(.system(size: config.fontSize, weight: .medium))
            .shadow(color: appState.darkMode ? .black.opacity(0.5) : .clear,
                        radius: appState.darkMode ? 1 : 0,
                        x: appState.darkMode ? 1 : 0,
                        y: appState.darkMode ? 1 : 0)
    }
}


#Preview {
    CustomText(config: .init(text: "Test"))
}

