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
        StrokeText(text: config.title, width: 2, color: .white)
                    .foregroundColor(config.titleColor)
                    .font(.system(size: config.fontSize, weight: .bold))

    }
}

struct StrokeText: View {
    let text: String
    let width: CGFloat
    let color: Color

    var body: some View {
        ZStack{
            ZStack{
                Text(text).offset(x:  width, y:  width)
                Text(text).offset(x: -width, y: -width)
                Text(text).offset(x: -width, y:  width)
                Text(text).offset(x:  width, y: -width)
            }
            .foregroundColor(color)
            Text(text)
        }
    }
}

#Preview {
    CustomHeader(config: .init(title: "Test"))
}
