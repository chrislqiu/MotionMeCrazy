//
//  CustomHeader.swift
//  MotionMeCrazy
//
//  Created by Rachel La on 2/6/25.
//

import SwiftUI

struct CustomHeaderConfig {
    let title: String
    var titleColor: Color = .darkBlue
    var fontSize: CGFloat = 30
}

struct CustomHeader: View {
    let config: CustomHeaderConfig
    var body: some View {
        Text(config.title)
            .foregroundColor(config.titleColor)
            .font(.system(size: config.fontSize, weight: .bold))
            .padding(.top, 10) 
    }
}


#Preview {
    CustomHeader(config: .init(title: "Test"))
}
