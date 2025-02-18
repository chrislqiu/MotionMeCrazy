//
//  CustomTextField.swift
//  MotionMeCrazy
//
//  Created by Rachel La on 2/11/25.
//

import SwiftUI

struct CustomTextFieldConfig {
    @Binding var text: String
    var placeholder: String
    var cornerRadius: CGFloat = 15
    var backgroundColor: Color = Color.white.opacity(0.25)
    var borderColor: Color = .darkBlue
    var borderWidth: CGFloat = 3
    var padding: CGFloat = 10
}

struct CustomTextField: View {
    let config: CustomTextFieldConfig
    var body: some View {
        TextField(config.placeholder, text: config.$text)
            .padding(config.padding)
            .background(config.backgroundColor)
            .cornerRadius(config.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: config.cornerRadius)
                    .stroke(config.borderColor, lineWidth: config.borderWidth)
            )
            .padding(.horizontal, 10)
    }
}

#Preview {
    @Previewable @State var searchText = "test"
    CustomTextField(config: .init(text:$searchText, placeholder: "Search..."))
}
