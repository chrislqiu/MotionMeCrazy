//
//  ProfilePageView.swift
//  MotionMeCrazy
//
//  Created by Rachel La on 2/6/25.
//

import SwiftUI

struct ProfilePageView: View {
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()
            VStack {
                CustomHeader(config: CustomHeaderConfig(title: "Profile Page"))
                CustomButton(config: CustomButtonConfig(title: "Edit") {})
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .frame(width: 100)
                    .padding(.bottom)
            }
        }
        
        
    }
}

#Preview {
    ProfilePageView()
}

