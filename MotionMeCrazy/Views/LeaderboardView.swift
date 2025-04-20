//
//  LeaderboardView.swift
//  MotionMeCrazy
//
//  Created by Tea Lazareto on 4/9/25.
//

import SwiftUI

struct LeaderboardView: View {
    @State private var publicLeaderboardVisible = true
    @ObservedObject var userViewModel: UserViewModel
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var errorMessage: String? = nil
    
    @State private var leaderboardEntries: [(username: String, profilePicId: String, score: Int)] = []
    @State private var friendsLeaderboardEntries: [(username: String, profilePicId: String, score: Int)] = []
    

    private func refreshLeaderboard() {
        fetchTopScores()
        fetchTopFriendScores(userId: userViewModel.userid, gameId: 1)
       
    }


    var body: some View {
        NavigationView {
            ZStack {
                Image(appState.darkMode ? "background_dm" : "background")
                    .resizable()
                    .ignoresSafeArea()

                VStack {
                    CustomHeader(config: .init(title: "Leaderboard"))

                    HStack {
                        //CustomSelectedButton(config: .init(title: "Public", width: 100, action: { withAnimation { publicLeaderboardVisible = true }}))
                        CustomButton(config: .init(title: "Public", width: 100, buttonColor: publicLeaderboardVisible ? .darkBlue : .white.opacity(0.25), action: { withAnimation { publicLeaderboardVisible = true }}))
                        CustomButton(config: .init(title: "Friends", width: 100, buttonColor: !publicLeaderboardVisible ? .darkBlue : .white.opacity(0.5), action: { withAnimation { publicLeaderboardVisible = false }}))

                        /*Button(action: {
                            withAnimation { publicLeaderboardVisible = true }
                        }) {
                            Text("Public")
                                .font(.headline)
                                .padding()
                                .background(publicLeaderboardVisible ? Color.darkBlue : Color.clear)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Button(action: {
                            withAnimation { publicLeaderboardVisible = false }
                        }) {
                            Text("Friends")
                                .font(.headline)
                                .padding()
                                .background(!publicLeaderboardVisible ? Color.darkBlue : Color.clear)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }*/
                    }
                    .padding()

                    ZStack {
                        if publicLeaderboardVisible {
                            VStack {
                                CustomHeader(config: .init(title: "Public Leaderboard", fontSize: 26))

                                ScrollView {
                                    VStack(spacing: 10) {
                                        ForEach(leaderboardEntries, id: \.username) { entry in
                                            HStack {
                                                Image(entry.profilePicId)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 40, height: 40)
                                                    .clipShape(Circle())
                                                    .overlay(Circle().stroke(.darkBlue, lineWidth: 3))

                                                VStack(alignment: .leading) {
                                                    CustomText(config: .init(text: entry.username))
                                                    CustomText(config: .init(text: "Score: \(entry.score)", fontSize: 18))

                                                    /*Text(entry.username)
                                                        .font(.headline)
                                                        .foregroundColor(.white)
                                                    Text("Score: \(entry.score)")
                                                        .font(.subheadline)
                                                        .foregroundColor(.gray)*/
                                                }

                                                Spacer()
                                            }
                                            .padding()
                                            .background(appState.darkMode ? .darkBlue.opacity(0.8) : .white.opacity(0.8))
                                            .cornerRadius(10)
                                        }
                                    }
                                    .padding()
                                }
                            }
                            .transition(.move(edge: .leading))
                        } else {
                            VStack {
                                CustomHeader(config: .init(title: "Friends Leaderboard", fontSize: 26))

                                ScrollView {
                                    VStack(spacing: 10) {
                                        ForEach(friendsLeaderboardEntries, id: \.username) { entry in
                                            HStack {
                                                Image(entry.profilePicId)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 40, height: 40)
                                                    .clipShape(Circle())
                                                    .overlay(Circle().stroke(.darkBlue, lineWidth: 3))

                                                VStack(alignment: .leading) {
                                                    CustomText(config: .init(text: entry.username))
                                                    CustomText(config: .init(text: "Score: \(entry.score)", fontSize: 18))
                                                    /*Text(entry.username)
                                                        .font(.headline)
                                                        .foregroundColor(.white)
                                                    Text("Score: \(entry.score)")
                                                        .font(.subheadline)
                                                        .foregroundColor(.gray)*/
                                                }

                                                Spacer()
                                            }
                                            .padding()
                                            .background(appState.darkMode ? .darkBlue.opacity(0.8) : .white.opacity(0.8))
                                            .cornerRadius(10)
                                        }
                                    }
                                    .padding()
                                }
                            }
                            .transition(.move(edge: .trailing))
                        }
                    }
                    .animation(.easeInOut, value: publicLeaderboardVisible)
                }
            }
            .background(Color.black.ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
//                leading: Button(action: {
//                    presentationMode.wrappedValue.dismiss()
//                }) {
//                    Image(systemName: "arrow.left.circle.fill")
//                        .font(.title)
//                        .foregroundColor(appState.darkMode ? .white : .darkBlue)
//                },
                trailing: Button(action: {
                    refreshLeaderboard()
                }) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.title)
                        .foregroundColor(appState.darkMode ? .white : .darkBlue)
                }
            )
        }
        .onAppear {
            refreshLeaderboard()
        }
        
    }
    //get public high scores
    private func fetchTopScores() {
        let urlString = APIHelper.getBaseURL() + "/stats/topScores"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            self.errorMessage = "Invalid URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                    print("Invalid response from server")
                    self.errorMessage = "Invalid response from server"
                    return
                }

                if httpResponse.statusCode == 200 {
                    do {
                        if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                            let scores = jsonArray.compactMap { entry in
                                if let username = entry["username"] as? String,
                                   let profilePicId = entry["profilepicid"] as? String,
                                   let score = entry["score"] as? Int {
                                    return (username, profilePicId, score)
                                }
                                return nil
                            }
                            self.leaderboardEntries = scores
                        }
                    } catch {
                        print("Failed to decode JSON: \(error.localizedDescription)")
                        self.errorMessage = "Failed to decode JSON: \(error.localizedDescription)"
                    }
                } else {
                    print("Failed to fetch top scores. Status code: \(httpResponse.statusCode)")
                    self.errorMessage = "Failed to fetch top scores. Status code: \(httpResponse.statusCode)"
                }
            }
        }.resume()
    }
    
    //get public high scores
    private func fetchTopFriendScores(userId: Int, gameId: Int?) {
        let urlString = APIHelper.getBaseURL() + "/stats/topFriendsScores?userId=\(userId)&gameId=1"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            self.errorMessage = "Invalid URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                    print("Invalid response from server")
                    self.errorMessage = "Invalid response from server"
                    return
                }

                if httpResponse.statusCode == 200 {
                    do {
                        if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                            let scores = jsonArray.compactMap { entry in
                                if let username = entry["username"] as? String,
                                   let profilePicId = entry["profilepicid"] as? String,
                                   let score = entry["highscore"] as? Int {
                                    return (username, profilePicId, score)
                                }
                                return nil
                            }
                            self.friendsLeaderboardEntries = scores
                        }
                    } catch {
                        print("Failed to decode JSON: \(error.localizedDescription)")
                        self.errorMessage = "Failed to decode JSON: \(error.localizedDescription)"
                    }
                } else {
                    print("Failed to fetch top FRIEND scores. Status code: \(httpResponse.statusCode)")
                    self.errorMessage = "Failed to fetch top FRIEND scores. Status code: \(httpResponse.statusCode)"
                }
            }
        }.resume()
    }
    
}
