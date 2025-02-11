//
//  PendingPageView.swift
//  MotionMeCrazy
//
//  Created by Rachel La on 2/11/25.
//

import SwiftUI

struct PendingPageView: View {
    // TODO: fetch friends from db
    let sampleUsers = [
        User(id: 1, username: "RachelLa", profilePicture: "pfp1"),
        User(id: 2, username: "JohnDoe", profilePicture: "pfp2"),
        User(id: 3, username: "JaneSmith", profilePicture: "pfp1")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("background")
                    .resizable()
                    .ignoresSafeArea()
                VStack(alignment: .center, spacing: 10) {
                    CustomHeader(config: CustomHeaderConfig(title: "Pending Requests"))
                    
                    HStack(alignment: .top, spacing: 10) {
                        CustomButton(config: CustomButtonConfig(
                            title: "All",
                            width: 75,
                            destination: AnyView(FriendsPageView())
                        ))
                        
                        CustomSelectedButton(config:
                                                CustomSelectedButtonConfig(title: "Pending", width: 100) {})
                        
                        
                        
                        CustomButton(config:
                                        CustomButtonConfig(title: "Sent", width: 75) {})
                    }
                    .padding(.top, 10)
                    
                    List(sampleUsers) { user in
                        UserRowView(user: user)
                            .listRowBackground(Color.clear)
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
            }
        }
    }
}

#Preview {
    PendingPageView()
}
