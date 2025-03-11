//
//  FriendsPageView.swift
//  MotionMeCrazy
//
//  Created by Rachel La on 2/6/25.
//

import SwiftUI

struct FriendsPageView: View {
    @State private var searchText = ""
    @State private var errorMessage: String?  // For displaying errors
    @State private var friends: [UserViewModel] = []
    
    @ObservedObject var userViewModel: UserViewModel
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("background")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack(alignment: .center, spacing: 10) {
                    CustomHeader(config: CustomHeaderConfig(title: "Friends"))
                    
                    if !appState.offlineMode {
                        
                        HStack(alignment: .top, spacing: 10) {
                            CustomSelectedButton(config:
                                                    CustomSelectedButtonConfig(title: "All", width: 75) {})
                            
                            CustomButton(config: CustomButtonConfig(
                                title: "Pending",
                                width: 100,
                                buttonColor: .darkBlue,
                                destination: AnyView(PendingPageView(userViewModel: userViewModel))
                            ))
                            
                            CustomButton(config:
                                            CustomButtonConfig(title: "Sent", width: 75, buttonColor: .darkBlue) {})
                        }
                        .padding(.top, 10)
                        
                        VStack(alignment: .center, spacing: 10) {
                            SearchBar(searchText: $searchText, userViewModel: userViewModel)
                                .padding()
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
                    } else {
                        Spacer()
                        
                        Text("This page is not available in offline mode")
                            .font(.title2)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding()
                            .accessibilityIdentifier("offlineMessage")
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
            }
        }.onAppear {
            if !appState.offlineMode {
                getFriends()
            }
        }
    }
    
    
    func getFriends() {
        friends.removeAll()
        
        guard let url = URL(string: APIHelper.getBaseURL() + "/friend?userId=\(userViewModel.userid)") else {
            print("Invalid URL for user \(userViewModel.userid)")
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
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    if let data = data {
                        do {
                            let users = try JSONDecoder().decode([UserResponse].self, from: data)
                            self.friends = users.map { user in
                                UserViewModel(userid: user.userid,
                                              username: user.username,
                                              profilePicId: user.profilepicid)
                            }
                            print(self.friends)
                            print("HI")
                            self.errorMessage = nil
                        } catch {
                            self.errorMessage = "Failed to parse user data"
                        }
                    }
                } else {
                    self.errorMessage = "Failed to fetch user data"
                }
            }
        }.resume()
    }
}




struct SearchBar: View {
    @Binding var searchText: String
    @ObservedObject var userViewModel: UserViewModel
    @State private var errorMessage: String?
    @State private var result: UserViewModel?
    @State private var hasSearched = false
    @State private var hasSentRequest = false
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.darkBlue)
                    .font(.system(size: 24, weight: .bold))
                
                CustomTextField(config: CustomTextFieldConfig(text: $searchText, placeholder: "Search..."))
                
                CustomButton(config: CustomButtonConfig(title: "Search", width: 100, buttonColor: .darkBlue) {findUser()})
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.darkBlue)
                            .font(.system(size: 24, weight: .bold))
                    }
                }
            }
            .padding(.horizontal, 10)
            
            if let userResult = result {
                VStack(){
                    UserRowView(user: userResult)
                        .padding()
                        .background(Color.clear)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    CustomButton(
                        config: CustomButtonConfig(
                            title: "Add", width: 80,
                            buttonColor: .darkBlue
                        ) {
                            addRequest()
                        })
                }
                
            } else if hasSearched {
                CustomText(config: CustomTextConfig(text: "No users found", titleColor: .darkBlue, fontSize: 20))
                
            }
        }.alert("Friend request has been sent", isPresented: $hasSentRequest) {
            Button("OK", role: .cancel) { hasSentRequest = false; hasSearched = false; searchText = ""; result = nil }
        }
        
    }
    
    func findUser() {
        hasSearched = true
        guard let url = URL(string: APIHelper.getBaseURL() + "/user?userId=\(searchText)") else {
            self.result = nil
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    self.errorMessage = "Network error, please try again"
                    self.result = nil
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if let data = data {
                            do {
                                let user = try JSONDecoder().decode(UserResponse.self, from: data)
                                self.result = UserViewModel(userid: user.userid, username: user.username, profilePicId: user.profilepicid)
                                if let userResult = self.result {
                                    print(userResult.userid)
                                } else {
                                    self.result = nil
                                    print("No user found")
                                }
                                
                            } catch {
                                self.result = nil
                                self.errorMessage = "Failed to parse user data"
                            }
                        }
                    } else {
                        self.result = nil
                        self.errorMessage = "Failed to fetch user data"
                    }
                }
            }
        }.resume()
    }
    
    func addRequest() {
        guard let url = URL(string: APIHelper.getBaseURL() + "/friend/send") else {
            print("Invalid URL")
            return
        }
        
        guard let userResult = result else {
            errorMessage = "Error retrieving friend id"
            return
        }
        
        let body = [
            "userid": userViewModel.userid,
            "friendid": userResult.userid
        ]
        
        print(body)
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body)
        else {
            print("Failed to encode JSON")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    self.errorMessage = "Network error, please try again"
                    return
                }
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        print("Friend request sent!")
                        hasSentRequest = true
                    } else {
                        self.errorMessage =
                        "Error accepting friend request, please try again"
                    }
                }
            }
        }.resume()
        
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
            }
            
            Spacer()
        }
        .padding(.vertical, 5).accessibilityIdentifier("userRow")
    }
    
}

#Preview {
    //    FriendsPageView()
}
