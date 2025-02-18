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
                            buttonColor: .darkBlue,
                            destination: AnyView(FriendsPageView())
                        ))
                        
                        CustomSelectedButton(config:
                                                CustomSelectedButtonConfig(title: "Pending", width: 100) {})
                        
                        CustomButton(config:
                                        CustomButtonConfig(title: "Sent", width: 75, buttonColor: .darkBlue) {})
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

private struct UserRowView: View {
    let user: User

    var body: some View {
        HStack {
            Image(user.profilePicture)
                .resizable()
                .scaledToFit()
                .frame(width: 75, height: 75)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 3))

            VStack(alignment: .leading) {
                CustomText(config: CustomTextConfig(text: user.username))
                CustomText(config: CustomTextConfig(text: "ID: \(user.id)"))
                
                HStack {
                    CustomButton(config:
                        CustomButtonConfig(title: "Accept", width: 100, buttonColor: .darkBlue) {})
                    
                    CustomButton(config:
                                    CustomButtonConfig(title: "Decline", width: 100, buttonColor: .lightBlue) {})
                }
            }
            
            

            Spacer()
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    PendingPageView()
}
