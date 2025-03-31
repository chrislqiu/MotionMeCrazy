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

    //game stats
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

                // to filter by time period
//                Menu {
//                    Button("Past Day") {
//                        selectedTimePeriod = "Past Day"
//                        fetchUserStatistics(userId: userViewModel.userid, gameId: selectedGameId, days: 1)
//                    }
//                    Button("Past Week") {
//                        selectedTimePeriod = "Past Week"
//                        fetchUserStatistics(userId: userViewModel.userid, gameId: selectedGameId, days: 7)
//                    }
//                    Button("Past Month") {
//                        selectedTimePeriod = "Past Month"
//                        fetchUserStatistics(userId: userViewModel.userid, gameId: selectedGameId, days: 30)
//                    }
//                } label: {
//                    HStack {
//                        Text("High Scores From The: \(selectedTimePeriod)")
//                            .foregroundColor(.white)
//                            .fontWeight(.bold)
//                        Image(systemName: "arrowtriangle.down.fill")
//                            .foregroundColor(.white)
//                    }
//                    .padding()
//                    .background(Color("DarkBlue"))
//                    .cornerRadius(10)
//                }
//                .padding(.bottom, 20)

                // Highscore and Time Played Display
                VStack {
                    Text("Total Time Played: \(timePlayed)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("DarkBlue"))
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

                    // filter menu for personal game stats
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

    // filtered game stats for scroll view
    var filteredGameStats: [(session_id: Int, gameName: String, icon: String, score: Int, hours: Int)] {
        var sortedStats: [(session_id: Int, gameName: String, icon: String, score: Int, hours: Int)]

        if filterType == "viewAll" || filterType == "longestSession" {
            // sorted alphabetically by game name if its a non score related filter
            sortedStats = gameStats
            sortedStats = sortedStats.sorted { $0.gameName < $1.gameName } // sort alphabetically

            if filterType == "longestSession" {
                var uniqueGameNames: [String] = [] // look for unique games
                var longestSessions: [(session_id: Int, gameName: String, icon: String, score: Int, hours: Int)] = []

                // go through highest scoring game stats
                for game in gameStats {
                    if !uniqueGameNames.contains(game.gameName) {
                        uniqueGameNames.append(game.gameName)

                        // find longest game session for the game
                        let longestSession = gameStats.filter { $0.gameName == game.gameName }
                            .max { $0.hours < $1.hours }

                        if let longest = longestSession {
                            longestSessions.append(longest)
                        }
                    }
                }
                longestSessions.sort { $0.hours > $1.hours } //sort highest to lowest
                sortedStats = longestSessions
            }
        } else if filterType == "highScore" {
            sortedStats = gameStats.sorted { $0.score > $1.score } // Sort by highest score first
        } else {
            sortedStats = gameStats // Default to all game stats if no filter
        }

        return sortedStats
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
