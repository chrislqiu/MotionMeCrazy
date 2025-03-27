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

    // place holder for temporary games
    @State private var gameStats:
        [(
            session_id: Int, gameName: String, icon: String, score: Int,
            hours: Int
        )] = [
            (
                session_id: 1, gameName: "Hole In Wall", icon: "figure.run",
                score: 1000, hours: 6
            ),
            (
                session_id: 2, gameName: "Game 2", icon: "gamecontroller.fill",
                score: 0, hours: 0
            ),
            (
                session_id: 3, gameName: "Hole In Wall", icon: "figure.run",
                score: 10, hours: 1
            ),
        ]

    // filter
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
                        fetchUserStatistics(
                            userId: userViewModel.userid,
                            gameId: selectedGameId, timePeriod: "Past Day")
                    }
                    Button("Past Week") {
                        selectedTimePeriod = "Past Week"
                        fetchUserStatistics(
                            userId: userViewModel.userid,
                            gameId: selectedGameId, timePeriod: "Past Week")
                    }
                    Button("Past Month") {
                        selectedTimePeriod = "Past Month"
                        fetchUserStatistics(
                            userId: userViewModel.userid,
                            gameId: selectedGameId, timePeriod: "Past Month")
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

                // highscore based on time period
                VStack {
                    Text("High Score: \(highScore)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("DarkBlue"))
                        .padding(.bottom, 10)
                    Text("Time Played: \(timePlayed)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("DarkBlue"))
                    // filter
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
                            Image(
                                systemName: "line.3.horizontal.decrease.circle"
                            )
                            .foregroundColor(.darkBlue)
                            .padding()
                        }
                        .padding(.trailing, 5)
                    }

                    // scroll view for personal game sessions
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(filteredGameStats, id: \.session_id) {
                                game in
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

                    // clear and share
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
            fetchUserStatistics(
                userId: userViewModel.userid, gameId: selectedGameId,
                timePeriod: "Past Day")
        }
    }

    // filter the game stats scroll view
    // TODO: need to fetch the actual statistics from db
    var filteredGameStats:
        [(
            session_id: Int, gameName: String, icon: String, score: Int,
            hours: Int
        )]
    {
        if filterType == "viewAll" {
            return gameStats
        }

        // filter based on scores or time
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

    func fetchUserStatistics(userId: Int, gameId: Int?, timePeriod: String) {
        let calendar = Calendar.current
        let now = Date()
        var duration = 0
        var startDate: Date?

        switch timePeriod {
        case "Past Day":
            duration = 1
            startDate = calendar.date(byAdding: .day, value: -1, to: now)
        case "Past Week":
            duration = 7
            startDate = calendar.date(byAdding: .day, value: -7, to: now)
        case "Past Month":
            duration = 30
            startDate = calendar.date(byAdding: .month, value: -1, to: now)
        default:
            startDate = nil
        }

        let dateFormatter = ISO8601DateFormatter()
        let startDateString =
            startDate != nil ? dateFormatter.string(from: startDate!) : ""

        var urlString =
            APIHelper.getBaseURL() + "/stats/userStatistics?userId=\(userId)"
        if let gameId = gameId {
            urlString += "&gameId=\(gameId)"
        }
        if !startDateString.isEmpty {
            urlString += "&startDate=\(startDateString)"
            urlString += "&days=\(duration)"
        }

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
                    self.errorMessage =
                        "Network error: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                    let data = data
                else {
                    print("Invalid response from server")
                    self.errorMessage = "Invalid response from server"
                    return
                }

                if httpResponse.statusCode == 200 {
                    do {
                        if let json = try JSONSerialization.jsonObject(
                            with: data, options: []) as? [String: Any]
                        {
                            if let timePlayedStr = json["time_played"]
                                as? String
                            {
                                self.timePlayed = formatTimePlayed(
                                    timePlayedStr)
                            }
                            if let scores = json["scores"] as? [[String: Any]] {
                                let highestScore =
                                    scores.compactMap { $0["score"] as? Int }
                                    .max() ?? 0
                                self.highScore = highestScore
                            }
                        }
                    } catch {
                        print(
                            "Failed to decode JSON: \(error.localizedDescription)"
                        )
                        self.errorMessage =
                            "Failed to decode JSON: \(error.localizedDescription)"
                    }
                } else {
                    print(
                        "Failed to fetch stats. Status code: \(httpResponse.statusCode)"
                    )
                    self.errorMessage =
                        "Failed to fetch stats. Status code: \(httpResponse.statusCode)"
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
        guard
            let url = URL(
                string: APIHelper.getBaseURL()
                    + "/stats/userGameSessions?userId=\(userId)")
        else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage =
                        "Network error: \(error.localizedDescription)"
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        print("User Stats Deleted!")
                        selectedTimePeriod = "Past Day"
                        fetchUserStatistics(
                            userId: userViewModel.userid,
                            gameId: selectedGameId, timePeriod: "Past Day")
                        self.errorMessage = nil
                    } else {
                        self.errorMessage =
                            "Failed to delete stats. Status code: \(httpResponse.statusCode)"
                    }
                }
            }
        }.resume()
    }
}

#Preview {
    // StatisticsPageView(user: "test")
}
