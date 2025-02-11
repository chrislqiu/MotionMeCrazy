//
//  FriendsPageView.swift
//  MotionMeCrazy
//
//  Created by Rachel La on 2/6/25.
//

import SwiftUI

struct FriendsPageView: View {
    @State private var searchText = ""
    
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
                    CustomHeader(config: CustomHeaderConfig(title: "Friends"))
                    
                    HStack(alignment: .top, spacing: 10) {
                        CustomSelectedButton(config:
                            CustomSelectedButtonConfig(title: "All", width: 75) {})
                        
                        CustomButton(config: CustomButtonConfig(
                            title: "Pending",
                            width: 100,
                            destination: AnyView(PendingPageView()) 
                        ))
                        
                        CustomButton(config:
                            CustomButtonConfig(title: "Sent", width: 75) {})
                    }
                    .padding(.top, 10)

                    VStack(alignment: .center, spacing: 10) {
                        SearchBar(searchText: $searchText)
                            .padding()
                        CustomText(config: CustomTextConfig(text: "You are searching for: \(searchText)"))
                    }
                    
                    List(sampleUsers) { user in
                        UserRowView(user: user)
                            .listRowBackground(Color.clear)
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
                .padding(.horizontal, 20)
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

struct User: Identifiable {
    let id: Int
    let username: String
    let profilePicture: String
}

struct UserRowView: View {
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
            }

            Spacer()
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    FriendsPageView()
}
