//
//  GameCenterPageView.swift
//  MotionMeCrazy
//
//  Created by Tea Lazareto 2/13/25.
//

import SwiftUI

struct GameData: Decodable {
    let game_id: Int
    let session_count: Int
}

enum PlayCountType {
    case everyone, me
}

struct GameCenterPageView: View {
    @State private var selectedGame: Int = 0
    @State private var sortOption: SortOption = .default // Enum to track sorting options
    @State private var playCountType: PlayCountType = .everyone // Enum to track play count type
    @State private var games: [(gameId: Int, name: String, icon: String, buttonColor: Color, sessionCount: Int, destination: AnyView)] = []
    @State private var showComingSoonPopup: Bool = false
    @ObservedObject var userViewModel: UserViewModel
    @EnvironmentObject var appState: AppState
    
    enum SortOption {
        case `default`, leastPopular, mostPopular
    }
    
    init(userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Image(appState.darkMode ? "background_dm" : "background")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack {
                    // Header and sort button
                    VStack {
                        HStack {
                            Spacer()
                            // Button to go to Daily Missions
                            NavigationLink(destination: DailyMissionsView(userId: userViewModel.userid)) {
                                Image(systemName: "checkmark.seal.text.page.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                            }
                            .padding(.trailing, 20)
                            
                            Menu {
                                Button("Most Popular") {
                                    sortOption = .mostPopular
                                    fetchGameData()
                                }
                                Button("Least Popular") {
                                    sortOption = .leastPopular
                                    fetchGameData()
                                }
                                Button("Revert to Default") {
                                    sortOption = .default
                                    fetchGameData()
                                }
                            } label: {
                                Image(systemName: "arrow.up.arrow.down.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                            }
                            .padding(.trailing, 20)
                            
                            Menu {
                                Button("Personal") {
                                    playCountType = .me
                                    fetchGameData()
                                }
                                Button("Everyone") {
                                    playCountType = .everyone
                                    fetchGameData()
                                }
                            } label: {
                                Image(systemName: "number.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                            }
                            .padding(.trailing, 20)
                        }
                        
                        CustomHeader(config: .init(title: "Game Center"))
                            .padding(.top, 10)
                    }
                    
                    Spacer()
                    
                    // Game selection
                    TabView(selection: $selectedGame) {
                        ForEach(Array(games.indices), id: \.self) { index in
                            SelectGame(game: games[index], playCountType: playCountType)
                                .scaleEffect(selectedGame == index ? 1.2 : 1.0)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: 325)
            
                    Spacer()
                    //leaderboard button
                    HStack {
                        Spacer()
                        NavigationLink(destination: LeaderboardView(userViewModel: userViewModel)) {
                            HStack(spacing: 6) {
                                Image(systemName: "list.number")
                                    .font(.title2)
                                Text("Leaderboard")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.darkBlue)
                            .cornerRadius(10)
                        }
                        .padding(.trailing, 20)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            games = [
                (gameId: 1, name: "Hole In Wall", icon: "figure.run", buttonColor: .darkBlue, sessionCount: 0, destination: AnyView(HIWGameLobbyView(userId: userViewModel.userid, gameId: 1))),
                (gameId: 2, name: "Game 2", icon: "gamecontroller.fill", buttonColor: .darkBlue, sessionCount: 0, destination: AnyView(Text("Game 2 Coming Soon!")))
            ]
            fetchGameData()
        }
    }
    
    private func fetchGameData() {
        let playCountQuery: String
        switch playCountType {
        case .everyone:
            playCountQuery = "everyone"
        case .me:
            playCountQuery = "me"
        }
        
        guard let url = URL(string: APIHelper.getBaseURL() + "/stats/games?playCountType=\(playCountQuery)&userId=\(userViewModel.userid)") else {
            print("Invalid URL")
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching game data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let decodedGames: [GameData] = try JSONDecoder().decode([GameData].self, from: data)
                
                DispatchQueue.main.async {
                    for i in 0..<games.count {
                        if let updatedGame = decodedGames.first(where: { $0.game_id == games[i].gameId }) {
                            games[i].sessionCount = updatedGame.session_count
                        }
                    }
                    sortGames()
                }
                
            } catch {
                print("Error decoding game data: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    private func sortGames() {
        switch sortOption {
        case .mostPopular:
            games.sort { $0.sessionCount > $1.sessionCount }
        case .leastPopular:
            games.sort { $0.sessionCount < $1.sessionCount }
        case .default:
            break // Keep default order
        }
    }
}

struct SelectGame: View {
    @EnvironmentObject var appState: AppState
    let game: (gameId: Int, name: String, icon: String, buttonColor: Color, sessionCount: Int, destination: AnyView)
    let playCountType: PlayCountType
    
    var body: some View {
        VStack {
            Image(systemName: game.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(game.buttonColor)
                .padding(.bottom, 10)
            
            if !appState.offlineMode {
                        HStack {
                            if playCountType == .everyone {
                                Image(systemName: "person.3.fill") // Icon for everyone
                                    .foregroundColor(appState.darkMode ? .white  : .darkBlue)
                            }
                            else {
                                Image(systemName: "person.fill") // Icon for everyone
                                    .foregroundColor(appState.darkMode ? .white : .darkBlue)
                            }
                            Text(playCountText)
                                .font(.headline)
                                .foregroundColor(appState.darkMode ? Color.white : .darkBlue)
                        }
                    }
            
            CustomButton(config: .init(title: game.name, width: 250, buttonColor: game.buttonColor, destination: game.destination))
            
        }
        .frame(width: 250, height: 150)
    }
    
    private var playCountText: String {
        switch playCountType {
        case .everyone:
            return "Played \(game.sessionCount) times"
        case .me:
            return "You played this \(game.sessionCount) times"
        }
    }
}

#Preview {
    GameCenterPageView(userViewModel: UserViewModel(userid: 421, username: "JazzyLegend633", profilePicId: "pfp2"))
}
