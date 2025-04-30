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
                Image(appState.darkMode ? "background_dm" : "background")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack(alignment: .center, spacing: 10) {
                    CustomHeader(config: CustomHeaderConfig(title: appState.localized("Friends")))
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                    if !appState.offlineMode {
                        
                        HStack(alignment: .top, spacing: 10) {
                            CustomSelectedButton(config: CustomSelectedButtonConfig(
                                title: appState.localized("All"),
                                width: 75) {}
                            )
                            
                            CustomButton(config: CustomButtonConfig(
                                title: appState.localized("Pending"),
                                width: 100,
                                buttonColor: .darkBlue,
                                destination: AnyView(PendingPageView(userViewModel: userViewModel))
                            ))
                            
                            CustomButton(config: CustomButtonConfig(
                                title: appState.localized("Sent"),
                                width: 75,
                                buttonColor: .darkBlue,
                                destination: AnyView(SentPageView(userViewModel: userViewModel))
                            ))
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
                        
                    } else {
                        
                        CustomText(config: .init(text: appState.localized("This page is not available in offline mode")))
                            .accessibilityIdentifier("offlineMessage")
                        
                    }
                    Spacer()

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
                                              profilePicId: user.profilepicid!)
                            }
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
    @EnvironmentObject var appState: AppState
    @Binding var searchText: String
    @ObservedObject var userViewModel: UserViewModel
    @State private var errorMessage: String?
    @State private var result: UserViewModel?
    @State private var hasSearched = false
    @State private var hasSentRequest = false
    @State private var hasAlreadySent = false
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.darkBlue)
                    .font(.system(size: 24, weight: .bold))
                
                CustomTextField(config: CustomTextFieldConfig(text: $searchText, placeholder: appState.localized("Search...")))
                
                CustomButton(config: CustomButtonConfig(title: appState.localized("Search"), width: 100, buttonColor: .darkBlue) {findUser()})
                
                if !searchText.isEmpty {
                    Button(action: { searchText = ""; hasSearched = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(appState.darkMode ? .white : .darkBlue)
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
                            title: appState.localized("Add"), width: 80,
                            buttonColor: .darkBlue
                        ) {
                            addRequest()
                        })
                }
                
            } else if hasSearched {
                CustomText(config: CustomTextConfig(text: appState.localized("No users found"), fontSize: 20))
                
            }
        }.alert(appState.localized("Friend request has been sent"), isPresented: $hasSentRequest) {
            Button("OK", role: .cancel) { hasSentRequest = false; hasSearched = false; searchText = ""; result = nil }
        }.alert(appState.localized("Friend request already exists and is pending"), isPresented: $hasAlreadySent) {
            Button("OK", role: .cancel) { hasAlreadySent = false; hasSearched = false; searchText = ""; result = nil }
        }
        
        if let errorMessage = errorMessage {
            Text(errorMessage)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .padding(.top, 5)
                .accessibilityIdentifier("errorMessage")
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
                                self.result = UserViewModel(userid: user.userid, username: user.username, profilePicId: user.profilepicid!)
                                if let userResult = self.result {
                                    print(userResult.userid)
                                } else {
                                    self.result = nil
                                }
                                
                            } catch {
                                self.result = nil
                                self.errorMessage = "Failed to parse user data"
                            }
                        }
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
                        "Error, please try again"
                    }
                }
            }
        }.resume()
        
    }
    
}

private struct UserRowView: View {
    let user: UserViewModel
    @EnvironmentObject var appState: AppState
    
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
                CustomText(config: CustomTextConfig(text:  String(format: appState.localized("ID: %d"), user.userid)))
            }
            
            Spacer()
        }
        .padding(.vertical, 5).accessibilityIdentifier("userRow")
    }
    
}

#Preview {
    //    FriendsPageView()
}
