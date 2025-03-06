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
    @State private var requests: [FriendRequest] = []
    
    @ObservedObject var userViewModel: UserViewModel
    
    @State private var navigateToFriendsPage = false
    
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
                            destination: AnyView(FriendsPageView(userViewModel: userViewModel))
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
                                UserRowView(user: user, navigateToFriendsPage: $navigateToFriendsPage)
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
            NavigationLink(
                destination: FriendsPageView(userViewModel: userViewModel),
                isActive: $navigateToFriendsPage
            ) {
                EmptyView()
            }
        }.onAppear() {
            getFriends(userId: userViewModel.userid, requests: $requests)
        }
    }
}

func getFriends(userId: Int, requests: Binding<[FriendRequest]>) {
    requests.wrappedValue.removeAll()
    
    guard let url = URL(string: APIHelper.getBaseURL() + "/friend/requests/pending?userid=\(userId)") else {
        print("Invalid URL")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        DispatchQueue.main.async {
            if error != nil {
                print("Network error, please try again")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    if let data = data {
                        do {
                            let userResponses = try JSONDecoder().decode([FriendRequest].self, from: data)
                            
                            for userResponse in userResponses {
                                let userViewModel = FriendRequest(request_id: userResponse.request_id, userid: userResponse.userid, username: userResponse.username, profilepicid: userResponse.profilepicid)
                                requests.wrappedValue.append(userViewModel)
                            }
                            
                            print("Successfully retrieved pending request information!")
                        } catch {
                            print("Error decoding response:", error)
                        }
                    }
                } else {
                    print("Error retrieving pending request information, please try again")
                }
            }
        }
    }.resume()
}


struct FriendRequest: Codable {
    let request_id: Int
    let userid: Int
    let username: String
    let profilepicid: String
}

private struct UserRowView: View {
    @State private var errorMessage: String?  // For displaying errors
    let user: FriendRequest
    @Binding var navigateToFriendsPage: Bool
    
    var body: some View {
        HStack {
            Image(user.profilepicid)
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
                        acceptRequest()
                    })
                
                CustomButton(
                    config: CustomButtonConfig(
                        title: "Decline", width: 100,
                        buttonColor: .lightBlue
                    ) {
                        declineRequest()
                    })
                
            }
            Spacer()
        }.contentShape(Rectangle())
            .padding(.vertical, 5)
    }
    
    // Accepts friend request
    func acceptRequest() {
        guard let url = URL(string: APIHelper.getBaseURL() + "/friend/accept") else {
            print("Invalid URL")
            return
        }
        
        let body = [
            "request_id": user.request_id,
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
                        self.navigateToFriendsPage = true
                    } else {
                        self.errorMessage =
                        "Error accepting friend request, please try again"
                    }
                }
            }
        }.resume()
    }
    
    // Decline friend request
    func declineRequest() {
        guard let url = URL(string: APIHelper.getBaseURL() + "/friend/request/?request_id=\(user.request_id)") else {
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
                        self.navigateToFriendsPage = true
                    } else {
                        self.errorMessage =
                        "Error deleting friend request, please try again"
                    }
                }
            }
        }.resume()
        
    }
}

#Preview {
    //    PendingPageView()
}
