//
//  CustomHeader.swift
//  MotionMeCrazy
//
//  Created by Rachel La on 2/6/25.
//

import SwiftUI

struct CustomHeaderConfig {
    let title: String
    var fontSize: CGFloat = 30
}

struct CustomHeader: View {
    @EnvironmentObject var appState: AppState
    let config: CustomHeaderConfig
    var body: some View {
        Text(config.title)
            .foregroundColor(appState.darkMode ? .white : .darkBlue)
            .font(.system(size: config.fontSize, weight: .bold))
            .padding(.top, 10) 
    }
}


#Preview {
    CustomHeader(config: .init(title: "Test"))
}
