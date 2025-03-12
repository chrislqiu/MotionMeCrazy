//
//  SentPageView.swift
//  MotionMeCrazy
//
//  Created by Rachel La on 3/11/25.
//

import SwiftUI

struct SentPageView: View {
    @ObservedObject var userViewModel: UserViewModel
    
    @State private var errorMessage: String?
    @State private var requests: [FriendRequest] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("background")
                    .resizable()
                    .ignoresSafeArea()
                VStack(alignment: .center, spacing: 10) {
                    CustomHeader(config: CustomHeaderConfig(title: "Sent Requests"))
                    
                    HStack(alignment: .top, spacing: 10) {
                        CustomButton(config: CustomButtonConfig(
                            title: "All",
                            width: 75,
                            buttonColor: .darkBlue,
                            destination: AnyView(FriendsPageView(userViewModel: userViewModel))
                        ))
                        
                        CustomButton(config: CustomButtonConfig(
                            title: "Pending",
                            width: 100,
                            buttonColor: .darkBlue,
                            destination: AnyView(PendingPageView(userViewModel: userViewModel))
                        ))
                        
                        CustomSelectedButton(config: CustomSelectedButtonConfig(
                            title: "Sent",
                            width: 75) {}
                        )
                    }
                    .padding(.top, 10)
                    
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(requests, id: \.userid) { user in
                                UserRowView(user: user)
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
            getSentRequests(userId: userViewModel.userid, requests: $requests)
        }
    }
    
    
}

func getSentRequests(userId: Int, requests: Binding<[FriendRequest]>) {
    requests.wrappedValue.removeAll()

    guard let url = URL(string: APIHelper.getBaseURL() + "/friend/requests/sent?userid=\(userId)") else {
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
                            print("Successfully retrieved sent request information!")
                        } catch {
                            print("Error decoding response:", error)
                        }
                    }
                } else {
                    print("Error retrieving sent request information, please try again")
                }
            }
        }
    }.resume()
}

private struct UserRowView: View {
    let user: FriendRequest
    
    var body: some View {
        HStack {
            Image(user.profilepicid)
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


