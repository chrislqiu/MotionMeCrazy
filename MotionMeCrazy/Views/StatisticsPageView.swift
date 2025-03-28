//
//  StatisticsPageView.swift
//  MotionMeCrazy
//
//  Created by Chris Qiu on 2/8/25.
//
import SwiftUI

struct StatisticsPageView: View {
    @State private var highScore: Int = 0
    @State private var timePlayed: String = "0h 0m"
    @State private var errorMessage: String?
    @ObservedObject var userViewModel: UserViewModel
    @State private var selectedTimePeriod: String = "Past Day"
    @State private var selectedGameId: Int? = nil

    // Placeholder for game statistics
    @State private var gameStats: [
        (session_id: Int, gameName: String, icon: String, score: Int, hours: Int)
    ] = []

    // Filter
    @State private var filterType: String = "viewAll"

    var body: some View {
        ZStack {
            // Background
            Image("background")
                .resizable()
                .ignoresSafeArea()

            VStack {
                // Navigation Bar
                HStack {
                    Spacer()
                    Text("Statistics")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color("DarkBlue"))

                Spacer()

                // Time Filter Menu
                Menu {
                    Button("Past Day") {
                        selectedTimePeriod = "Past Day"
                        fetchUserStatistics(userId: userViewModel.userid, gameId: selectedGameId, days: 1)
                    }
                    Button("Past Week") {
                        selectedTimePeriod = "Past Week"
                        fetchUserStatistics(userId: userViewModel.userid, gameId: selectedGameId, days: 7)
                    }
                    Button("Past Month") {
                        selectedTimePeriod = "Past Month"
                        fetchUserStatistics(userId: userViewModel.userid, gameId: selectedGameId, days: 30)
                    }
                } label: {
                    HStack {
                        Text("High Scores From The: \(selectedTimePeriod)")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                        Image(systemName: "arrowtriangle.down.fill")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color("DarkBlue"))
                    .cornerRadius(10)
                }
                .padding(.bottom, 20)

                // Highscore and Time Played Display
                VStack {
//                    Text("High Score: \(highScore)")
//                        .font(.title2)
//                        .fontWeight(.bold)
//                        .foregroundColor(Color("DarkBlue"))
//                        .padding(.bottom, 10)
                    Text("Time Played: \(timePlayed)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("DarkBlue"))

                    // Filter Menu
                    HStack {
                        Spacer()
                        Menu {
                            Button("High Score") {
                                filterType = "highScore"
                            }
                            Button("Longest Session") {
                                filterType = "longestSession"
                            }
                            Button("View All") {
                                filterType = "viewAll"
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .foregroundColor(.darkBlue)
                                .padding()
                        }
                        .padding(.trailing, 5)
                    }

                    // Scroll View for Personal Game Sessions
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(filteredGameStats, id: \.session_id) { game in
                                HStack {
                                    Image(systemName: game.icon)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.white)
                                        .padding(.trailing, 10)

                                    VStack(alignment: .leading) {
                                        Text(game.gameName)
                                            .font(.headline)
                                            .foregroundColor(.white)

                                        Text(
                                            "\(filterType == "highScore" ? "Score: \(game.score)" : "Session Time: \(game.hours)h")"
                                        )
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    }

                                    Spacer()
                                }
                                .padding()
                                .background(Color("DarkBlue").opacity(0.8))
                                .cornerRadius(10)
                            }
                        }
                        .padding()
                    }

                    // Clear and Share Buttons
                    HStack {
                        Spacer()
                        CustomButton(
                            config: CustomButtonConfig(
                                title: "Share",
                                width: 100,
                                buttonColor: .darkBlue,
                                action: {
                                    // TODO: Add share function
                                }
                            )
                        )
                        CustomButton(
                            config: CustomButtonConfig(
                                title: "Clear",
                                width: 100,
                                buttonColor: .darkBlue,
                                action: {
                                    clearStats(userId: userViewModel.userid)
                                }
                            )
                        )
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                    Spacer()
                }
                .padding(.top, 20)

                Spacer()
            }
        }
        .onAppear {
            fetchUserStatistics(userId: userViewModel.userid, gameId: selectedGameId, days: 1)
        }
    }

    // Filter the game stats scroll view
    var filteredGameStats: [
        (session_id: Int, gameName: String, icon: String, score: Int, hours: Int)
    ] {
        if filterType == "viewAll" {
            return gameStats
        }

        // Filter based on scores or time
        let grouped = Dictionary(grouping: gameStats, by: { $0.gameName })
        return grouped.flatMap { (gameName, games) in
            let filteredGame = games.max { (game1, game2) in
                if filterType == "highScore" {
                    return game1.score < game2.score
                } else {
                    return game1.hours < game2.hours
                }
            }
            return filteredGame != nil ? [filteredGame!] : []
        }
    }

    func fetchUserStatistics(userId: Int, gameId: Int?, days: Int) {
        var urlString = APIHelper.getBaseURL() + "/stats/userStatistics?userId=\(userId)&days=\(days)"
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
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            if let totalTimePlayed = json["total_time_played"] as? String {
                                self.timePlayed = formatTimePlayed(totalTimePlayed)
                            }

                            if let scores = json["scores"] as? [[String: Any]] {
                                self.gameStats = scores.compactMap { scoreEntry in
                                    if let score = scoreEntry["score"] as? Int,
                                       let gameName = scoreEntry["gameName"] as? String,
                                       let icon = scoreEntry["icon"] as? String,
                                       let hours = scoreEntry["hours"] as? Int,
                                       let sessionId = scoreEntry["sessionId"] as? Int {
                                        return (session_id: sessionId, gameName: gameName, icon: icon, score: score, hours: hours)
                                    }
                                    return nil
                                }

                                // Update high score
                                self.highScore = self.gameStats.max { $0.score < $1.score }?.score ?? 0
                            }
                        }
                    } catch {
                        print("Failed to decode JSON: \(error.localizedDescription)")
                        self.errorMessage = "Failed to decode JSON: \(error.localizedDescription)"
                    }
                } else if httpResponse.statusCode == 404 {
                    print("User statistics not found (404)")
                    self.errorMessage = "User statistics not found"
                    self.highScore = 0
                    self.timePlayed = "0h 0m"
                } else {
                    print("Failed to fetch stats. Status code: \(httpResponse.statusCode)")
                    self.errorMessage = "Failed to fetch stats. Status code: \(httpResponse.statusCode)"
                }
            }
        }.resume()
    }

    func formatTimePlayed(_ time: String) -> String {
        let components = time.split(separator: ":").compactMap { Int($0) }
        guard components.count == 3 else { return "0h 0m" }

        let hours = components[0]
        let minutes = components[1]

        return "\(hours)h \(minutes)m"
    }

    func clearStats(userId: Int) {
        guard let url = URL(string: APIHelper.getBaseURL() + "/stats/userGameSessions?userId=\(userId)") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        print("User Stats Deleted!")
                        selectedTimePeriod = "Past Day"
                        fetchUserStatistics(userId: userViewModel.userid, gameId: selectedGameId, days: 1)
                        self.errorMessage = nil
                    } else {
                        self.errorMessage = "Failed to delete stats. Status code: \(httpResponse.statusCode)"
                    }
                }
            }
        }.resume()
    }
}


#Preview {
    // StatisticsPageView(user: "test")
}
