//
//  FriendsPageView.swift
//  MotionMeCrazy
//
//  Created by Rachel La on 2/6/25.
//

import SwiftUI

struct FriendsPageView: View {
    @State private var searchText = ""
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()
            VStack(alignment: .center, spacing: 125) {
                CustomHeader(config: CustomHeaderConfig(title: "Friends"))
                    .frame(maxWidth: .infinity, alignment: .center)
                HStack(alignment: .top, spacing: 20) {
                    
                    CustomButton(config:
                        CustomButtonConfig(title: "All", width: 75) {})
                    CustomButton(config:
                        CustomButtonConfig(title: "Pending", width: 100) {})
                    CustomButton(config:
                        CustomButtonConfig(title: "Sent", width: 75) {})
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 10){
                    SearchBar(searchText: $searchText)
                        .padding()
                    
                    Text("You are searching for: \(searchText)")
                }
                
                Spacer()
                
                
            }
        }
    }
    
}

struct SearchBar: View {
    @Binding var searchText: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.darkBlue)
            CustomTextField(config: CustomTextFieldConfig(text: $searchText, placeholder: "Search..."))
                            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill") // Clear button
                        .foregroundColor(.darkBlue)
                }
            }
            
            
        }
        .padding(.horizontal, 10)
    }
}

#Preview {
    FriendsPageView()
}
