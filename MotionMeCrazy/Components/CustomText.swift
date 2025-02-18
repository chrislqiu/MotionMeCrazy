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
    let config: CustomTextConfig
    var body: some View {
        Text(config.text)
            .foregroundColor(config.titleColor)
            .font(.system(size: config.fontSize, weight: .medium))
    }
}


#Preview {
    CustomText(config: .init(text: "Test"))
}

