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
                    
                    CustomSelectedButton(config:
                        CustomSelectedButtonConfig(title: "All", width: 75) {})
                    CustomButton(config:
                        CustomButtonConfig(title: "Pending", width: 100) {})
                    CustomButton(config:
                        CustomButtonConfig(title: "Sent", width: 75) {})
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 10){
                    SearchBar(searchText: $searchText)
                        .padding()
                    CustomText(config: CustomTextConfig(text: "You are searching for: \(searchText)"))
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
                .font(.system(size: 24, weight: .bold))
            CustomTextField(config: CustomTextFieldConfig(text: $searchText, placeholder: "Search..."))
                            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.darkBlue)
                        .font(.system(size: 24, weight: .bold))
                }
            }
            
            
        }
        .padding(.horizontal, 10)
    }
}

#Preview {
    FriendsPageView()
}
