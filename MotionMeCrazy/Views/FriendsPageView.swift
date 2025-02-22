//
//  FriendsPageView.swift
//  MotionMeCrazy
//
//  Created by Rachel La on 2/6/25.
//

import SwiftUI

struct FriendsPageView: View {
    // TODO: fetch userId
    @State private var userId = 194
    @State private var searchText = ""
    @State private var errorMessage: String?  // For displaying errors
    @State private var friends: [UserViewModel] = []
    
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
                            buttonColor: .darkBlue,
                            destination: AnyView(PendingPageView())
                        ))
                        
                        CustomButton(config:
                            CustomButtonConfig(title: "Sent", width: 75, buttonColor: .darkBlue) {})
                    }
                    .padding(.top, 10)

                    VStack(alignment: .center, spacing: 10) {
                        SearchBar(searchText: $searchText)
                            .padding()
                        CustomText(config: CustomTextConfig(text: "You are searching for: \(searchText)"))
                    }
                    
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(friends, id: \.userid) { user in
                                UserRowView(user: user)
                                    .padding()
                                    .background(Color.clear)
                                    .cornerRadius(10)
                                    .shadow(radius: 2)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    /*List(friends) { user in
                        UserRowView(user: user)
                            .listRowBackground(Color.clear)
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)*/
                }
                .padding(.horizontal, 20)
            }
        }.onAppear() {
            getFriendsId()
        }
    }
    
    func getFriendsId() {
        var friendIds: [Int] = []
        guard let url = URL(string: "http://localhost:3000/friend?userId=\(userId)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    self.errorMessage = "Network error, please try again"
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if let data = data {
                            do {
                                friendIds = try JSONDecoder().decode(Array<Int>.self, from: data)
                                print(friendIds)
                                self.getFriends(friendIds: friendIds)
                                self.errorMessage = nil
                            } catch {
                                self.errorMessage = "Failed to parse response"
                                print(error)
                            }
                        }
                        print("Successfully retrieved friend ids!")
                        self.errorMessage = nil
                    } else {
                        self.errorMessage =
                        "Username already exists, please try again"
                    }
                }
            }
        }.resume()
        
        
    }
    
    func getFriends(friendIds: Array<Int>) {
        for friendId in friendIds {
            guard let url = URL(string: "http://localhost:3000/user?userId=\(friendId)") else {
                print("Invalid URL")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if error != nil {
                        self.errorMessage = "Network error, please try again"
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            if let data = data {
                                do {
                                    let userViewModel = UserViewModel()
                                    let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
                                    print(userResponse)
                                    userViewModel.userid = userResponse.userid
                                    userViewModel.username = userResponse.username
                                    userViewModel.profilePicId = userResponse.profilepicid
                                    friends.append(userViewModel)
                                    self.errorMessage = nil
                                } catch {
                                    self.errorMessage = "Failed to parse response"
                                    print(error)
                                }
                            }
                            print("Successfully retrieved friend information!")
                            self.errorMessage = nil
                        } else {
                            self.errorMessage =
                            "Username already exists, please try again"
                        }
                    }
                }
            }.resume()
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

private struct UserRowView: View {
    let user: UserViewModel
    
    var body: some View {
        HStack {
            Image(user.profilePicId)
                .resizable()
                .scaledToFit()
                .frame(width: 75, height: 75)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.darkBlue, lineWidth: 3))

            VStack(alignment: .leading) {
                CustomText(config: CustomTextConfig(text: user.username))
                CustomText(config: CustomTextConfig(text: "ID: \(user.userid)"))
                
                CustomButton(config:
                                CustomButtonConfig(title: "Remove", width: 100, buttonColor: .lightBlue) {})
            }

            Spacer()
        }
        .padding(.vertical, 5).accessibilityIdentifier("userRow")
    }
}

#Preview {
    FriendsPageView()
}
