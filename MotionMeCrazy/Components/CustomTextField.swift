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
    var cornerRadius: CGFloat = 10
    var backgroundColor: Color = Color.white.opacity(0.25)
    var borderColor: Color = .darkBlue
    var borderWidth: CGFloat = 1
    var padding: CGFloat = 8
    //let width: CGFloat
    //let action: () -> Void
    //var titleColor: Color = .white
    //var fontSize: CGFloat = 20
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
    /*var body: some View {
        ZStack {
        TextField("Search...", text: $searchText)
            .padding(8)
            .background(Color(.systemGray6)) // Light gray background
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
        }
    }*/
}

#Preview {
    @Previewable @State var searchText = "test"
    CustomTextField(config: .init(text:$searchText, placeholder: "Search..."))
}
