//
//  PendingPageView.swift
//  MotionMeCrazy
//
//  Created by Rachel La on 2/11/25.
//

import SwiftUI

private var friendRequests: [FriendRequest] = []

struct PendingPageView: View {
    // TODO: fetch userId
    @State private var userId = 194
    @State private var errorMessage: String?  // For displaying errors
    @State private var requests: [UserViewModel] = []
    
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
                    
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(requests, id: \.userid) { user in
                                UserRowView(user: user, requests: $requests)
                                    .padding()
                                    .background(Color.clear)
                                    .cornerRadius(10)
                                    .shadow(radius: 2)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }.onAppear() {
            getRequestIds()
        }
    }
    
    // Get request ids
    func getRequestIds() {
        var requestIds: [Int] = []
        guard let url = URL(string: "http://localhost:3000/friend/requests/pending?userid=\(userId)") else {
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
                            if let jsonString = String(data: data, encoding: .utf8) {
                                    print("Raw response: \(jsonString)")
                                }
                                do {
                                    friendRequests = try JSONDecoder().decode([FriendRequest].self, from: data)
                                        print(friendRequests)
                                        requestIds = friendRequests.map { $0.userid }
                                        self.getFriends(friendIds: requestIds)
                                        self.errorMessage = nil
                                } catch {
                                    self.errorMessage = "Failed to parse response"
                                    print(error)
                                }
                        }
                        print("Successfully retrieved pending request id!")
                        self.errorMessage = nil
                    } else {
                        self.errorMessage =
                        "Error retrieving pending request id, please try again"
                    }
                }
            }
        }.resume()
    }
    
    // get friends from friend ids
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
                                    userViewModel.userid = userResponse.userid
                                    userViewModel.username = userResponse.username
                                    userViewModel.profilePicId = userResponse.profilepicid
                                    requests.append(userViewModel)
                                    self.errorMessage = nil
                                } catch {
                                    self.errorMessage = "Failed to parse response"
                                    print(error)
                                }
                            }
                            print("Successfully retrieved pending request information!")
                            self.errorMessage = nil
                        } else {
                            self.errorMessage =
                            "Error retrieving pending request information, please try again"
                        }
                    }
                }
            }.resume()
        }
    }
}

struct FriendRequest: Codable {
    let request_id: Int
    let userid: Int
    let friendid: Int
    let ispending: Bool
    let created_at: String
}

private struct UserRowView: View {
    @State private var errorMessage: String?  // For displaying errors
    let user: UserViewModel
    @Binding var requests: [UserViewModel]
                            
    var body: some View {
        HStack {
            Image(user.profilePicId)
                .resizable()
                .scaledToFit()
                .frame(width: 75, height: 75)
                .clipShape(Circle())
                .overlay(Circle().stroke(.darkBlue, lineWidth: 3))

            VStack(alignment: .leading) {
                CustomText(config: CustomTextConfig(text: user.username))
                CustomText(config: CustomTextConfig(text: "ID: \(user.userid)"))
                
                
                CustomButton(
                    config: CustomButtonConfig(
                        title: "Accept", width: 100,
                        buttonColor: .darkBlue
                    ) {
                        acceptRequest(userid: user.userid)
                    })
                
                CustomButton(
                    config: CustomButtonConfig(
                        title: "Decline", width: 100,
                        buttonColor: .lightBlue
                    ) {
                        declineRequest(userid: user.userid)
                    })
                
            }
            Spacer()
        }.contentShape(Rectangle())
        .padding(.vertical, 5)
    }
    
    // Accepts friend request
    func acceptRequest(userid: Int) {
        if let friendRequest = friendRequests.first(where: { $0.userid == userid }) {
            print(friendRequest)
            
            guard let url = URL(string: "http://localhost:3000/friend/accept") else {
                print("Invalid URL")
                return
            }
            
            let body = [
                "request_id": friendRequest.request_id,
                "user_id": friendRequest.userid,
                "friend_id": friendRequest.friendid
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
                            print("Friend request accepted!")
                            requests.removeAll{$0.userid == userid}
                            self.errorMessage = nil
                        } else {
                            self.errorMessage =
                            "Error accepting friend requeest, please try again"
                        }
                    }
                }
            }.resume()
        } else {
            print("No friend request found for userid \(userid)")
        }
    }
    
    // Decline friend request
    func declineRequest(userid: Int) {
        if let friendRequest = friendRequests.first(where: { $0.userid == userid }) {
            print(friendRequest.request_id)
            guard let url = URL(string: "http://localhost:3000/friend/request/?request_id=\(friendRequest.request_id)") else {
                print("Invalid URL")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if error != nil {
                        self.errorMessage = "Network error, please try again"
                        return
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            print("Friend request deleted!")
                            requests.removeAll{$0.userid == userid}
                            self.errorMessage = nil
                        } else {
                            self.errorMessage =
                            "Error deleting friend request, please try again"
                        }
                    }
                }
            }.resume()
            
        } else {
            print("No friend request found for userid \(userid)")
        }

    }
}

#Preview {
    PendingPageView()
}
